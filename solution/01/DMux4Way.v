`timescale 1ns/1ps

// DMux4Way：1 分 4，sel[1] 为高位
// 对应 nand2tetris Project 1 的 DMux4Way.hdl
module n2t_dmux4way (
    input  in,
    input  [1:0] sel,
    output a,
    output b,
    output c,
    output d
);
    wire ab, cd;
    n2t_dmux u_ab(.in(in), .sel(sel[1]), .a(ab), .b(cd));
    n2t_dmux u_a(.in(ab), .sel(sel[0]), .a(a), .b(b));
    n2t_dmux u_b(.in(cd), .sel(sel[0]), .a(c), .b(d));
endmodule
