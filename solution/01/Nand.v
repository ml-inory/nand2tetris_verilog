`timescale 1ns/1ps

// ============================================================
// 原语：Nand（课程中唯一的底层门，其余芯片均从它搭建）
// 对应 nand2tetris Project 1 的 Nand.hdl
// ============================================================
module n2t_nand (
    input  a,
    input  b,
    output out
);
    assign out = ~(a & b);
endmodule
