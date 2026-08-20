`timescale 1ns/1ps

// PE：脉动阵列中的单个乘累加单元（MAC）。
//
// 数据流约定（经典 weight-stationary 脉动阵列）：
//   a_in    从左侧流入，a_out 向右流出（每拍移动一格）
//   psum_in 从上方流入，psum_out 向下方流出（累加结果逐拍下移）
//   w_in    在 w_load 为高时写入 PE 内部权重寄存器，之后保持不变
//
// 计算语义（有符号）：
//   psum_out = psum_in + a_in * w
//
// 时序：Project 06 使用正规上升沿（posedge）提交，与真实 FPGA 一致。
// 注意：Hack 官方部分（Project 1/2/3/5）为了对齐官方测试向量仍用 negedge。
//
// Project 06 为自定义扩展（非官方 nand2tetris 题目），后续模块：
//   n2t_systolic_array -> n2t_conv_unit -> n2t_npu
module n2t_pe #(
    parameter A_W = 8,   // 激活/输入数据位宽（有符号）
    parameter W_W = 8,   // 权重位宽（有符号）
    parameter P_W = 32   // 累加器位宽（有符号）
) (
    input  clk,
    input  arst,   // async reset（异步复位，高有效）
    input  w_load,
    input  signed [W_W-1:0] w_in,
    input  signed [A_W-1:0] a_in,
    input  signed [P_W-1:0] psum_in,
    output reg signed [W_W-1:0] w_out,
    output reg signed [A_W-1:0] a_out,
    output reg signed [P_W-1:0] psum_out
);
    reg signed [W_W-1:0] w;

    always @(posedge clk or posedge arst) begin
        if (arst) begin
            w        <= {W_W{1'b0}};
            w_out    <= {W_W{1'b0}};
            a_out    <= {A_W{1'b0}};
            psum_out <= {P_W{1'b0}};
        end else begin
            if (w_load) w <= w_in;
            w_out    <= w;
            a_out    <= a_in;
            psum_out <= psum_in + a_in * w;
        end
    end
endmodule
