`timescale 1ns/1ps

// And：out = a & b，由 Nand + Not 构成
// 对应 nand2tetris Project 1 的 And.hdl
module n2t_and (
    input  a,
    input  b,
    output out
);
    wire nand_out;
    n2t_nand u_nand(.a(a), .b(b), .out(nand_out));
    n2t_not  u_not(.in(nand_out), .out(out));
endmodule
