`timescale 1ns/1ps

// ALU：Hack 芯片的核心算术逻辑单元，按课程方式用门级/部件级搭建
// 对应 nand2tetris Project 2 的 ALU.hdl
//
// 功能：
//   zx: x 置 0       nx: x 取反     zy: y 置 0
//   ny: y 取反       f: 1=加 0=与   no: 输出取反
//   zr: out==0       ng: out<0（最高位）
module n2t_alu (
    input  [15:0] x,
    input  [15:0] y,
    input         zx,
    input         nx,
    input         zy,
    input         ny,
    input         f,
    input         no,
    output [15:0] out,
    output        zr,
    output        ng
);
    wire [15:0] xz, xnn, xn;   // x 预处理
    wire [15:0] yz, ynn, yn;   // y 预处理
    wire [15:0] and_out, add_out, f_out, not_out, alu_out;

    n2t_mux16 u_zx(.a(x), .b(16'h0000), .sel(zx), .out(xz));
    n2t_not16  u_nx_not(.in(xz), .out(xnn));
    n2t_mux16 u_nx(.a(xz), .b(xnn), .sel(nx), .out(xn));

    n2t_mux16 u_zy(.a(y), .b(16'h0000), .sel(zy), .out(yz));
    n2t_not16  u_ny_not(.in(yz), .out(ynn));
    n2t_mux16 u_ny(.a(yz), .b(ynn), .sel(ny), .out(yn));

    n2t_and16 u_and(.a(xn), .b(yn), .out(and_out));
    n2t_add16 u_add(.a(xn), .b(yn), .out(add_out));
    n2t_mux16 u_f(.a(and_out), .b(add_out), .sel(f), .out(f_out));

    n2t_not16  u_no_not(.in(f_out), .out(not_out));
    n2t_mux16 u_no(.a(f_out), .b(not_out), .sel(no), .out(alu_out));
    assign out = alu_out;

    // zr：alu_out 全 0；ng：alu_out 最高位为 1
    wire low, high, zero;
    n2t_or8way u_zr_low(.in(alu_out[7:0]), .out(low));
    n2t_or8way u_zr_high(.in(alu_out[15:8]), .out(high));
    n2t_or u_zr_or(.a(low), .b(high), .out(zero));
    n2t_not u_zr_not(.in(zero), .out(zr));
    assign ng = alu_out[15];
endmodule
