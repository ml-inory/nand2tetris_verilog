`timescale 1ns/1ps

// RAM8：8 个 16 位寄存器，DMux8Way 译码写使能，Mux8Way16 读
// 对应 nand2tetris Project 3 的 RAM8.hdl
module n2t_ram8 (
    input         clk,
    input  [15:0] in,
    input         load,
    input  [2:0]  address,
    output [15:0] out
);
    wire [7:0] loads;
    wire [15:0] r0, r1, r2, r3, r4, r5, r6, r7;

    n2t_dmux8way u_dmux(
        .in(load), .sel(address),
        .a(loads[0]), .b(loads[1]), .c(loads[2]), .d(loads[3]),
        .e(loads[4]), .f(loads[5]), .g(loads[6]), .h(loads[7])
    );

    n2t_register u_r0(.clk(clk), .in(in), .load(loads[0]), .out(r0));
    n2t_register u_r1(.clk(clk), .in(in), .load(loads[1]), .out(r1));
    n2t_register u_r2(.clk(clk), .in(in), .load(loads[2]), .out(r2));
    n2t_register u_r3(.clk(clk), .in(in), .load(loads[3]), .out(r3));
    n2t_register u_r4(.clk(clk), .in(in), .load(loads[4]), .out(r4));
    n2t_register u_r5(.clk(clk), .in(in), .load(loads[5]), .out(r5));
    n2t_register u_r6(.clk(clk), .in(in), .load(loads[6]), .out(r6));
    n2t_register u_r7(.clk(clk), .in(in), .load(loads[7]), .out(r7));

    n2t_mux8way16 u_mux(
        .a(r0), .b(r1), .c(r2), .d(r3),
        .e(r4), .f(r5), .g(r6), .h(r7),
        .sel(address), .out(out)
    );
endmodule
