`timescale 1ns/1ps

// ConvUnit 单元测试：四组 (STRIDE, PAD) 配置并行跑同一份特征图/权重，
// 输出与内嵌 int8 参考实现（golden）逐元素一致。
// 框架默认 C_IN=C_OUT=4（阵列 N=4）以控制 iverilog 仿真时间。
//   配置：stride=1 pad=0（36 像素）、stride=1 pad=1（64 像素）、
//         stride=2 pad=0（9 像素）、stride=2 pad=1（16 像素）
module ConvUnit_tb;
    localparam H = 8, W = 8, C_IN = 4, C_OUT = 4, K = 3;
    localparam A_W = 8, W_W = 8, P_W = 32;

    reg clk = 1'b0;
    reg arst = 1'b1;
    reg wr_ifmap = 1'b0;
    reg start = 1'b0;
    reg [C_IN*A_W-1:0] ifmap_in = 0;
    reg [C_OUT*C_IN*K*K*W_W-1:0] w_data = 0;

    integer step = 0;
    integer npass = 0, nfail = 0;
    integer p, i, ic, oc, ky, kx;
    integer q0, q1, q2, q3;
    integer watchdog = 0;

    reg signed [A_W-1:0] ifmap_mem [0:H*W*C_IN-1];
    reg signed [W_W-1:0] wmem [0:C_OUT*C_IN*K*K-1];
    reg signed [P_W-1:0] gacc [0:C_OUT-1];

    wire [C_OUT*A_W-1:0] out_data0, out_data1, out_data2, out_data3;
    wire out_valid0, out_valid1, out_valid2, out_valid3;
    wire done0, done1, done2, done3;

    n2t_conv_unit #(.H(H), .W(W), .C_IN(C_IN), .C_OUT(C_OUT), .K(K),
                    .STRIDE(1), .PAD(0)) u_s1p0 (
        .clk(clk), .arst(arst), .wr_ifmap(wr_ifmap), .ifmap_in(ifmap_in),
        .w_data(w_data), .start(start),
        .out_data(out_data0), .out_valid(out_valid0), .done(done0)
    );
    n2t_conv_unit #(.H(H), .W(W), .C_IN(C_IN), .C_OUT(C_OUT), .K(K),
                    .STRIDE(1), .PAD(1)) u_s1p1 (
        .clk(clk), .arst(arst), .wr_ifmap(wr_ifmap), .ifmap_in(ifmap_in),
        .w_data(w_data), .start(start),
        .out_data(out_data1), .out_valid(out_valid1), .done(done1)
    );
    n2t_conv_unit #(.H(H), .W(W), .C_IN(C_IN), .C_OUT(C_OUT), .K(K),
                    .STRIDE(2), .PAD(0)) u_s2p0 (
        .clk(clk), .arst(arst), .wr_ifmap(wr_ifmap), .ifmap_in(ifmap_in),
        .w_data(w_data), .start(start),
        .out_data(out_data2), .out_valid(out_valid2), .done(done2)
    );
    n2t_conv_unit #(.H(H), .W(W), .C_IN(C_IN), .C_OUT(C_OUT), .K(K),
                    .STRIDE(2), .PAD(1)) u_s2p1 (
        .clk(clk), .arst(arst), .wr_ifmap(wr_ifmap), .ifmap_in(ifmap_in),
        .w_data(w_data), .start(start),
        .out_data(out_data3), .out_valid(out_valid3), .done(done3)
    );

    always #5 clk = ~clk;

    // golden：第 p 个输出像素（stride/pad 配置）的 C_OUT 通道打包（int8）
    function [C_OUT*A_W-1:0] golden_px;
        input integer p;
        input integer stride;
        input integer pad;
        integer oh, ow, go, gc, gky, gkx, giy, gix;
        begin
            oh = (H + 2*pad - K) / stride + 1;
            ow = (W + 2*pad - K) / stride + 1;
            for (go = 0; go < C_OUT; go = go + 1)
                gacc[go] = 0;
            for (gky = 0; gky < K; gky = gky + 1)
                for (gkx = 0; gkx < K; gkx = gkx + 1) begin
                    giy = (p / ow) * stride + gky - pad;
                    gix = (p % ow) * stride + gkx - pad;
                    if (giy >= 0 && giy < H && gix >= 0 && gix < W) begin
                        for (gc = 0; gc < C_IN; gc = gc + 1) begin
                            for (go = 0; go < C_OUT; go = go + 1)
                                gacc[go] = gacc[go] +
                                    ifmap_mem[(giy*W + gix)*C_IN + gc] *
                                    wmem[((go*C_IN + gc)*K*K + gky*K + gkx)];
                        end
                    end
                end
            golden_px = 0;
            for (go = 0; go < C_OUT; go = go + 1) begin
                if (gacc[go] < 0) gacc[go] = 0;
                else if (gacc[go] > 127) gacc[go] = 127;
                golden_px[go*A_W +: A_W] = gacc[go][A_W-1:0];
            end
        end
    endfunction

    task tst_check;
        input integer cfg;
        input integer q;
        input integer stride;
        input integer pad;
        input [C_OUT*A_W-1:0] got;
        reg [C_OUT*A_W-1:0] exp;
        begin
            exp = golden_px(q, stride, pad);
            step = step + 1;
            if (got !== exp) begin
                $display("FAIL [step %0d] cfg(s%0d p%0d) pixel %0d: got %h exp %h",
                         step, stride, pad, q, got, exp);
                nfail = nfail + 1;
            end else begin
                npass = npass + 1;
            end
        end
    endtask

    initial begin
        $display("=== ConvUnit ===");

        // 确定性小整数数据：特征图 -8..8，权重 -7..7（含负值）
        for (p = 0; p < H*W; p = p + 1)
            for (ic = 0; ic < C_IN; ic = ic + 1)
                ifmap_mem[p*C_IN + ic] = $signed((p*3 + ic*5) % 17 - 8);
        for (oc = 0; oc < C_OUT; oc = oc + 1)
            for (ic = 0; ic < C_IN; ic = ic + 1)
                for (ky = 0; ky < K; ky = ky + 1)
                    for (kx = 0; kx < K; kx = kx + 1)
                        wmem[((oc*C_IN + ic)*K*K + ky*K + kx)] =
                            $signed(((oc+1)*(ic+2) + ky*3 + kx) % 15 - 7);

        // 复位
        repeat (2) @(posedge clk);
        arst = 1'b0; #1;

        // 装载特征图（四个 DUT 共用同一份数据与控制）
        wr_ifmap = 1'b1;
        for (p = 0; p < H*W; p = p + 1) begin
            for (ic = 0; ic < C_IN; ic = ic + 1)
                ifmap_in[ic*A_W +: A_W] = ifmap_mem[p*C_IN + ic];
            @(posedge clk); #1;
        end
        wr_ifmap = 1'b0;

        // 装载权重并同时启动四个配置
        for (i = 0; i < C_OUT*C_IN*K*K; i = i + 1)
            w_data[i*W_W +: W_W] = wmem[i];
        start = 1'b1;
        @(posedge clk); #1;
        start = 1'b0;

        // 并行收集四个配置的输出
        q0 = 0; q1 = 0; q2 = 0; q3 = 0;
        while (q0 < 36 || q1 < 64 || q2 < 9 || q3 < 16) begin
            @(posedge clk); #1;
            // 看门狗：模板未实现 / FSM 卡死时防止仿真死等
            watchdog = watchdog + 1;
            if (watchdog > 20000) begin
                $display("FAIL: 仿真超时（%0d 拍仍未收齐输出）——检查 FSM 或输出时序",
                         watchdog);
                nfail = nfail + 1;
                $finish;
            end
            if (out_valid0 && q0 < 36) begin
                tst_check(0, q0, 1, 0, out_data0);
                q0 = q0 + 1;
            end
            if (out_valid1 && q1 < 64) begin
                tst_check(1, q1, 1, 1, out_data1);
                q1 = q1 + 1;
            end
            if (out_valid2 && q2 < 9) begin
                tst_check(2, q2, 2, 0, out_data2);
                q2 = q2 + 1;
            end
            if (out_valid3 && q3 < 16) begin
                tst_check(3, q3, 2, 1, out_data3);
                q3 = q3 + 1;
            end
        end

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule
