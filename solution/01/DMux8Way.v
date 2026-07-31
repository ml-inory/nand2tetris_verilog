`timescale 1ns/1ps

// DMux8Way：1 分 8，sel[2] 为高位
// 对应 nand2tetris Project 1 的 DMux8Way.hdl
module n2t_dmux8way (
    input  in,
    input  [2:0] sel,
    output a,
    output b,
    output c,
    output d,
    output e,
    output f,
    output g,
    output h
);
    wire abcd, efgh, ab, cd, ef, gh;
    n2t_dmux u0(.in(in), .sel(sel[2]), .a(abcd), .b(efgh));
    n2t_dmux u1(.in(abcd), .sel(sel[1]), .a(ab), .b(cd));
    n2t_dmux u2(.in(efgh), .sel(sel[1]), .a(ef), .b(gh));
    n2t_dmux u3(.in(ab), .sel(sel[0]), .a(a), .b(b));
    n2t_dmux u4(.in(cd), .sel(sel[0]), .a(c), .b(d));
    n2t_dmux u5(.in(ef), .sel(sel[0]), .a(e), .b(f));
    n2t_dmux u6(.in(gh), .sel(sel[0]), .a(g), .b(h));
endmodule
