`timescale 1ns/1ps

// ShiftRegister：参数化移位寄存器。
//
// 用途：
//   - 脉动阵列的“斜输入”：第 row 行延迟 row 拍；
//   - 脉动阵列的“输出对齐”：第 col 列延迟 N-1-col 拍。
//
// 行为：
//   en=1 时，每个 clk 上升沿把 in 移入第 0 级，旧数据依次右移；
//   out 是最后一级的输出（延迟 DEPTH 拍）。
//   arst 为异步复位（高有效），复位后所有级清零。
module n2t_shift_register #(
    parameter W       = 8,   // 数据位宽
    parameter DEPTH   = 4,   // 寄存器级数（延迟拍数）
    parameter RESET_VAL = 0  // 复位值
) (
    input  clk,
    input  arst,             // async reset（异步复位，高有效）
    input  en,               // 移位使能
    input  [W-1:0] in,
    output [W-1:0] out
);
    generate
        if (DEPTH == 0) begin : gen_pass
            assign out = in;
        end else begin : gen_shift
            reg [W-1:0] sr [0:DEPTH-1];
            integer i;

            always @(posedge clk or posedge arst) begin
                if (arst) begin
                    for (i = 0; i < DEPTH; i = i + 1)
                        sr[i] <= RESET_VAL[W-1:0];
                end else if (en) begin
                    sr[0] <= in;
                    for (i = 1; i < DEPTH; i = i + 1)
                        sr[i] <= sr[i-1];
                end
            end

            assign out = sr[DEPTH-1];
        end
    endgenerate
endmodule
