`timescale 1ns/1ps

// Not：out = ~in，由 Nand(a, a) 构成
// 对应 nand2tetris Project 1 的 Not.hdl
module n2t_not (
    input  in,
    output out
);
    n2t_nand u_nand(.a(in), .b(in), .out(out));
endmodule
