`timescale 1ns/1ps

// Mux16：16 位 2 选 1，sel 共用
// 对应 nand2tetris Project 1 的 Mux16.hdl
module n2t_mux16 (
    input  [15:0] a,
    input  [15:0] b,
    input         sel,
    output [15:0] out
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux
            n2t_mux u_mux(.a(a[i]), .b(b[i]), .sel(sel), .out(out[i]));
        end
    endgenerate
endmodule
