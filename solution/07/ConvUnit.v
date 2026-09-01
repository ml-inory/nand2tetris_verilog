`timescale 1ns/1ps

// ConvUnit：3x3 卷积 + 量化域 ReLU 的完整数据通路，复用 N x N 脉动阵列。
//
// 计算语义（int8）：
//   out[oy][ox][oc] = relu_clamp( sum_{ky,kx,ic}
//        ifmap[oy*STRIDE+ky-PAD][ox*STRIDE+kx-PAD][ic] * W[oc][ic][ky][kx] )
//   其中 iy/ix 越界按 0 补齐；relu_clamp(x) = (x<0) ? 0 : (x>127 ? 127 : x)
//
// 阵列复用方式（tap 外循环 + 通道 tiling）：
//   3x3xC_IN 的 im2col 行长度 9*C_IN > 阵列宽度 C_IN，按 (ky,kx) 拆成 9 个 tap；
//   每个 tap 是一次“C_IN 输入通道 x C_OUT 输出通道”的 C_IN x C_OUT GEMM，外部 int32
//   累加器把 9 个 tap 的部分和累加成一个输出像素的所有输出通道。
//   权重矩阵 W[oc][ic][ky][kx] 扁平化：w_data[((oc*C_IN+ic)*K*K+ky*K+kx)*W_W +: W_W]
//
// 状态机（控制器与数据通路分离）：
//   IDLE -> LOAD_W -> RUN -> DRAIN -> EMIT -> DONE
//     IDLE   等待 start（wr_ifmap=1 期间逐拍装载特征图）
//     LOAD_W 拉高 w_load 两拍，把第 tap 个 C_IN x C_OUT 权重矩阵写入阵列
//     RUN    先逐拍送 OPIX 个输入向量并收集输出，再送 FLUSH 个 0 冲掉流水
//     DRAIN  pending==0（本 tap 全部结果收完、流水已清）后切下一个 tap
//     EMIT   逐拍输出 relu_clamp 后的像素（out_valid=1）
//     DONE   done 脉冲一拍，回 IDLE
//
// 阵列延迟契约（来自 Project 06）：N x N 阵列从输入到对齐输出固定
// LAT = 2*(N-1) 拍；加上 a_data 寄存器驱动与控制器在同一边沿读到的是
// 阵列上一拍的值，控制器实际看到的结果比输入晚 LAT+1 拍。
// 因此 warmup = LAT+1：跳过前 LAT+1 个收集（0/无效值），保证累加索引
// 与输出向量一一对齐。
module n2t_conv_unit #(
    parameter H      = 8,   // 输入特征图高（本框架取 8）
    parameter W      = 8,   // 输入特征图宽（本框架取 8）
    // 注意：框架默认 C_IN=C_OUT=4（阵列 N=4），把参数调成 8 即复用 8x8
    // 阵列，逻辑不变；8x8 在 iverilog 里逐拍仿真开销较大，故默认取 4。
    parameter C_IN   = 4,   // 输入通道（须等于阵列 N）
    parameter C_OUT  = 4,   // 输出通道（须等于阵列 N）
    parameter K      = 3,   // 卷积核尺寸
    parameter STRIDE = 1,   // 1 或 2
    parameter PAD    = 0,   // 0 或 1
    parameter A_W    = 8,   // 激活位宽（有符号）
    parameter W_W    = 8,   // 权重位宽（有符号）
    parameter P_W    = 32   // 累加位宽（有符号）
) (
    input  clk,
    input  arst,                                // async reset（高有效）
    input  wr_ifmap,                            // 装载特征图：每拍写一个像素
    input  [C_IN*A_W-1:0] ifmap_in,             // 一个像素的 C_IN 个通道
    input  [C_OUT*C_IN*K*K*W_W-1:0] w_data,     // 扁平权重
    input  start,                               // 特征图装载完成后启动一次推理
    output reg [C_OUT*A_W-1:0] out_data,        // 一拍一个输出像素的 C_OUT 个通道
    output reg out_valid,                       // out_data 有效
    output reg done                             // 整幅图推理完成（脉冲一拍）
);
    localparam OH    = (H + 2*PAD - K) / STRIDE + 1;
    localparam OW    = (W + 2*PAD - K) / STRIDE + 1;
    localparam OPIX  = OH * OW;                 // 输出像素数
    localparam NPIX  = H * W;                   // 输入像素数
    localparam NTAP  = K * K;                   // 卷积核元素数
    localparam LAT   = 2 * (C_IN - 1);          // 阵列延迟 = 2*(N-1)
    // 冲流水所需 0 向量数：2*(N-1) 保证激活全清零；再加 1 拍以覆盖
    // 控制器晚一拍读到阵列输出，否则每个 tap 的最后一个像素会丢。
    localparam FLUSH = 2 * (C_IN - 1) + 1;

    // ---- 特征图缓冲：ifmap_mem[px*C_IN + ic]，LOAD 阶段写入 ----
    reg [A_W-1:0] ifmap_mem [0:NPIX*C_IN-1];
    reg [15:0] load_addr;

    // ---- 权重缓冲：wmem[((oc*C_IN+ic)*NTAP + tap)] ----
    reg [W_W-1:0] wmem [0:C_OUT*C_IN*NTAP-1];

    // ---- 输出累加器：acc[p*C_OUT + oc]，跨 tap 累加 ----
    reg signed [P_W-1:0] acc [0:OPIX*C_OUT-1];

    localparam S_IDLE = 0, S_LOAD_W = 1, S_RUN = 2, S_DRAIN = 3,
               S_EMIT = 4, S_DONE = 5;
    reg [2:0] state;

    reg [15:0] tap;        // 当前 tap 0..NTAP-1
    reg [15:0] real_fed;   // 已送出的向量数（真实向量 + 冲流水 0）
    reg [15:0] pending;    // 已送未收的向量数
    reg [15:0] accepted;   // 已正确累加的输出像素数
    reg [15:0] warmup;     // 跳过流水填充期的收集数
    reg w_load;
    reg [C_IN*A_W-1:0] a_data;

    wire [C_OUT*P_W-1:0] psum_out;
    wire [C_OUT*C_IN*W_W-1:0] w_vec;

    integer i, ic, oc;

    // ---- 第 tap 个权重矩阵：w_vec[ic*C_OUT+oc] = W[oc][ic][ky][kx] ----
    genvar gi, go;
    generate
        for (gi = 0; gi < C_IN; gi = gi + 1) begin : gen_wrow
            for (go = 0; go < C_OUT; go = go + 1) begin : gen_wcol
                assign w_vec[(gi*C_OUT + go)*W_W +: W_W] =
                    wmem[((go*C_IN + gi)*NTAP + tap)];
            end
        end
    endgenerate

    // ---- 输出像素 px 在 tap 处的窗口向量：vec[ic] = 窗口内第 ic 通道 ----
    // 注意：用函数实现并把循环变量做成函数局部量，避免多个组合块共享
    // 模块级 integer 形成组合反馈环（会严重拖慢仿真）。
    function [C_IN*A_W-1:0] window_vec;
        input [15:0] px;
        input [15:0] tp;
        integer foy, fox, fky, fkx, fiy, fix, fic;
        begin
            foy = (px / OW) * STRIDE;
            fox = (px % OW) * STRIDE;
            fky = tp / K;
            fkx = tp % K;
            fiy = foy + fky - PAD;
            fix = fox + fkx - PAD;
            for (fic = 0; fic < C_IN; fic = fic + 1) begin
                if (fiy >= 0 && fiy < H && fix >= 0 && fix < W)
                    window_vec[fic*A_W +: A_W] =
                        ifmap_mem[(fiy*W + fix)*C_IN + fic];
                else
                    window_vec[fic*A_W +: A_W] = {A_W{1'b0}};
            end
        end
    endfunction

    // RUN 阶段：先送 OPIX 个真实向量，再送 FLUSH 个 0 冲掉流水
    wire feed_real = (state == S_RUN) && (real_fed < OPIX);
    wire feed_zero = (state == S_RUN) && (real_fed >= OPIX) &&
                     (real_fed < OPIX + FLUSH);
    wire feeding   = feed_real || feed_zero;
    wire collecting = (state == S_RUN) && (pending > 0);

    function [A_W-1:0] relu_clamp(input signed [P_W-1:0] x);
        if (x < 0)
            relu_clamp = {A_W{1'b0}};
        else if (x > 127)
            relu_clamp = {1'b0, {A_W-1{1'b1}}};   // 127
        else
            relu_clamp = x[A_W-1:0];
    endfunction

    n2t_systolic_array #(
        .N(C_IN), .A_W(A_W), .W_W(W_W), .P_W(P_W)
    ) u_array (
        .clk(clk),
        .arst(arst),
        .w_load(w_load),
        .w_data(w_vec),
        .a_data(a_data),
        .psum_out(psum_out)
    );

    always @(posedge clk or posedge arst) begin
        if (arst) begin
            state    <= S_IDLE;
            load_addr <= 0;
            tap      <= 0;
            real_fed <= 0;
            pending  <= 0;
            accepted <= 0;
            warmup   <= LAT + 1;
            w_load   <= 0;
            a_data   <= {C_IN*A_W{1'b0}};
            out_valid <= 0;
            done     <= 0;
            out_data <= {C_OUT*A_W{1'b0}};
            for (i = 0; i < OPIX*C_OUT; i = i + 1)
                acc[i] <= {P_W{1'b0}};
        end else begin
            case (state)
                S_IDLE: begin
                    w_load <= 0;
                    done   <= 0;
                    a_data <= {C_IN*A_W{1'b0}};
                    if (wr_ifmap) begin
                        for (ic = 0; ic < C_IN; ic = ic + 1)
                            ifmap_mem[load_addr*C_IN + ic] <=
                                ifmap_in[ic*A_W +: A_W];
                        load_addr <= load_addr + 1;
                    end
                    if (start) begin
                        for (i = 0; i < C_OUT*C_IN*NTAP; i = i + 1)
                            wmem[i] <= w_data[i*W_W +: W_W];
                        for (i = 0; i < OPIX*C_OUT; i = i + 1)
                            acc[i] <= {P_W{1'b0}};
                        tap      <= 0;
                        real_fed <= 0;
                        pending  <= 0;
                        accepted <= 0;
                        warmup   <= LAT + 1;
                        load_addr <= 0;
                        state    <= S_LOAD_W;
                    end
                end
                S_LOAD_W: begin
                    a_data <= {C_IN*A_W{1'b0}};
                    if (w_load == 0) begin
                        w_load <= 1;   // 第一拍：拉高 w_load
                    end else begin
                        // 第二拍上升沿阵列装载权重，随后开始 RUN
                        w_load <= 0;
                        state  <= S_RUN;
                    end
                end
                S_RUN: begin
                    // a_data 寄存器驱动：阵列在下一拍采样，避免组合驱动
                    // 与阵列采样竞争导致的向量错位
                    if (feed_real)
                        a_data <= window_vec(real_fed, tap);
                    else
                        a_data <= {C_IN*A_W{1'b0}};
                    if (feeding)
                        real_fed <= real_fed + 1;
                    if (feeding && collecting)
                        pending <= pending;        // +1 -1
                    else if (feeding)
                        pending <= pending + 1;
                    else if (collecting)
                        pending <= pending - 1;

                    if (collecting) begin
                        if (warmup > 0) begin
                            warmup <= warmup - 1;  // 跳过流水填充期的 0
                        end else if (accepted < OPIX) begin
                            for (oc = 0; oc < C_OUT; oc = oc + 1)
                                acc[accepted*C_OUT + oc] <=
                                    acc[accepted*C_OUT + oc] +
                                    $signed(psum_out[oc*P_W +: P_W]);
                            accepted <= accepted + 1;
                        end
                    end

                    if (real_fed >= OPIX + FLUSH && pending == 0) begin
                        if (tap + 1 < NTAP) begin
                            tap      <= tap + 1;
                            real_fed <= 0;
                            accepted <= 0;
                            warmup   <= LAT + 1;
                            state    <= S_LOAD_W;
                        end else begin
                            state    <= S_EMIT;
                            accepted <= 0;
                        end
                    end
                end
                S_EMIT: begin
                    if (accepted < OPIX) begin
                        for (oc = 0; oc < C_OUT; oc = oc + 1)
                            out_data[oc*A_W +: A_W] <=
                                relu_clamp(acc[accepted*C_OUT + oc]);
                        out_valid <= 1;
                        accepted <= accepted + 1;
                    end else begin
                        out_valid <= 0;
                        state <= S_DONE;
                    end
                end
                S_DONE: begin
                    done  <= 1;
                    state <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule
