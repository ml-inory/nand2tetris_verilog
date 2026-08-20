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
// 复位采用同步复位：rst 高电平时在 posedge 清零，避免 reset/clk 竞争。
module n2t_systolic_array #(
    parameter N    = 8,
    parameter A_W  = 8,
    parameter W_W  = 8,
    parameter P_W  = 32
) (
    input  clk,
    input  rst,
    input  w_load,
    input  [N*N*W_W-1:0] w_data, // N x N 权重矩阵，行主序
    input  [N*A_W-1:0] a_data,   // 每拍一个长度为 N 的输入向量
    output [N*P_W-1:0] psum_out  // 每拍一个长度为 N 的输出向量
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 docs/npu.md 与 solution/06/ 的完整实现。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-06 RTLDIR=assignment` 验证。

endmodule
