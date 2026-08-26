`timescale 1ns/1ps

// SystolicArray：N x N 的 weight-stationary 脉动阵列。
//
// 数据布局（行主序，扁平向量）：
//   w_data[row*N + col] = W[row][col]
//   a_data[row]         = A[row][k]（第 k 拍送入第 k 个输入向量）
//   psum_out[col]       = C[k][col]（输出已对齐，所有列同一拍出现）
//
// 计算语义：
//   C[k][col] = sum_{row=0..N-1} A[row][k] * W[row][col]
//
// 对应到卷积 GEMM：A 的行是输入通道、列是空间位置；W 的行是输入通道、
// 列是输出通道；C 的每一拍是一个空间位置上所有输出通道的结果。
// 也就是说，这个阵列天然适合“一次输出一个像素点的 N 个输出通道”。
//
// 时序：
//   1. w_load 为高时把 w_data 整体写入阵列（真实 NPU 中由 DMA/权重 SRAM
//      批量装载）；
//   2. 之后每个 clk 上升沿送一个 a_data 向量；
//   3. 底部结果先做“输出对齐”：第 col 列额外延迟 N-1-col 拍，
//      因此 psum_out 的所有列在同一拍出现；
//   4. 最后一个输入送入后再等 N-1 拍，开始逐拍输出完整结果。
//
// 输入对齐：行 i 的输入在阵列内部延迟 i 拍，实现经典脉动阵列的斜输入，
// 因此外部不需要自己打 skew，只要按 k 逐拍送数据即可。
module n2t_systolic_array #(
    parameter N    = 8,
    parameter A_W  = 8,
    parameter W_W  = 8,
    parameter P_W  = 32
) (
    input  clk,
    input  arst,   // async reset（异步复位，高有效）
    input  w_load,
    input  [N*N*W_W-1:0] w_data, // N x N 权重矩阵，行主序
    input  [N*A_W-1:0] a_data,   // 每拍一个长度为 N 的输入向量
    output [N*P_W-1:0] psum_out  // 每拍一个长度为 N 的输出向量
);

    // ---- 输入对齐：行 i 用移位寄存器延迟 i 拍 ----
    wire [N*A_W-1:0] a_skewed;
    genvar si;
    generate
        for (si = 0; si < N; si = si + 1) begin : gen_a_skew
            n2t_shift_register #(
                .W(A_W),
                .DEPTH(si)
            ) u_skew (
                .clk(clk),
                .arst(arst),
                .en(1'b1),
                .in(a_data[si*A_W +: A_W]),
                .out(a_skewed[si*A_W +: A_W])
            );
        end
    endgenerate

    // ---- PE 阵列内部连线（扁平向量）----
    wire [N*N*A_W-1:0] a_link;
    wire [N*N*P_W-1:0] psum_link;

    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_row
            for (j = 0; j < N; j = j + 1) begin : gen_col
                wire [A_W-1:0] pe_a_in;
                wire [P_W-1:0] pe_psum_in;

                // 每行最左侧 PE 接斜输入，其余 PE 接左侧邻居的 a_out
                if (j == 0) begin : gen_a_in_first
                    assign pe_a_in = a_skewed[i*A_W +: A_W];
                end else begin : gen_a_in_next
                    assign pe_a_in = a_link[(i*N + j-1)*A_W +: A_W];
                end

                // 最上方 psum 补 0，其余 PE 接上方邻居的 psum_out
                if (i == 0) begin : gen_psum_in_top
                    assign pe_psum_in = {P_W{1'b0}};
                end else begin : gen_psum_in_next
                    assign pe_psum_in = psum_link[((i-1)*N + j)*P_W +: P_W];
                end

                n2t_pe #(
                    .A_W(A_W),
                    .W_W(W_W),
                    .P_W(P_W)
                ) u_pe (
                    .clk(clk),
                    .arst(arst),
                    .w_load(w_load),
                    .w_in(w_data[(i*N + j)*W_W +: W_W]),
                    .a_in(pe_a_in),
                    .psum_in(pe_psum_in),
                    .w_out(),
                    .a_out(a_link[(i*N + j)*A_W +: A_W]),
                    .psum_out(psum_link[(i*N + j)*P_W +: P_W])
                );
            end
        end
    endgenerate

    // ---- 输出对齐：col 列用移位寄存器延迟 (N-1-col) 拍 ----
    wire [N*P_W-1:0] o_aligned;
    genvar so;
    generate
        for (so = 0; so < N; so = so + 1) begin : gen_o_align
            n2t_shift_register #(
                .W(P_W),
                .DEPTH(N-1-so)
            ) u_align (
                .clk(clk),
                .arst(arst),
                .en(1'b1),
                .in(psum_link[((N-1)*N + so)*P_W +: P_W]),
                .out(o_aligned[so*P_W +: P_W])
            );
        end
    endgenerate

    // ---- 底部输出 ----
    genvar c;
    generate
        for (c = 0; c < N; c = c + 1) begin : gen_out
            assign psum_out[c*P_W +: P_W] = o_aligned[c*P_W +: P_W];
        end
    endgenerate
endmodule
