`timescale 1ns/1ps

// Mux8Way16：8 路 16 位选择器，sel[2] 为高位
// 对应 nand2tetris Project 1 的 Mux8Way16.hdl
module n2t_mux8way16 (
    input  [15:0] a,
    input  [15:0] b,
    input  [15:0] c,
    input  [15:0] d,
    input  [15:0] e,
    input  [15:0] f,
    input  [15:0] g,
    input  [15:0] h,
    input  [2:0]  sel,
    output [15:0] out
);
    wire [15:0] ab, cd, ef, gh, abcd, efgh;
    n2t_mux16 u_ab(.a(a), .b(b), .sel(sel[0]), .out(ab));
    n2t_mux16 u_cd(.a(c), .b(d), .sel(sel[0]), .out(cd));
    n2t_mux16 u_ef(.a(e), .b(f), .sel(sel[0]), .out(ef));
    n2t_mux16 u_gh(.a(g), .b(h), .sel(sel[0]), .out(gh));
    n2t_mux16 u_abcd(.a(ab), .b(cd), .sel(sel[1]), .out(abcd));
    n2t_mux16 u_efgh(.a(ef), .b(gh), .sel(sel[1]), .out(efgh));
    n2t_mux16 u_out(.a(abcd), .b(efgh), .sel(sel[2]), .out(out));
endmodule
