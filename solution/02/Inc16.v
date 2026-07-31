`timescale 1ns/1ps

// Inc16：加 1，即 Add16(in, 1)
// 对应 nand2tetris Project 2 的 Inc16.hdl
module n2t_inc16 (
    input  [15:0] in,
    output [15:0] out
);
    n2t_add16 u_add(.a(in), .b(16'd1), .out(out));
endmodule
