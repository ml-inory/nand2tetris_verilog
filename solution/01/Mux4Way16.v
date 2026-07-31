`timescale 1ns/1ps

// Mux4Way16：4 路 16 位选择器，sel[1] 为高位
// 对应 nand2tetris Project 1 的 Mux4Way16.hdl
module n2t_mux4way16 (
    input  [15:0] a,
    input  [15:0] b,
    input  [15:0] c,
    input  [15:0] d,
    input  [1:0]  sel,
    output [15:0] out
);
    wire [15:0] ab, cd;
    n2t_mux16 u_ab(.a(a), .b(b), .sel(sel[0]), .out(ab));
    n2t_mux16 u_cd(.a(c), .b(d), .sel(sel[0]), .out(cd));
    n2t_mux16 u_out(.a(ab), .b(cd), .sel(sel[1]), .out(out));
endmodule
