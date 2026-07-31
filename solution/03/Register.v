`timescale 1ns/1ps

// Register：16 位寄存器，由 16 个 Bit 组成
// 对应 nand2tetris Project 3 的 Register.hdl
module n2t_register (
    input         clk,
    input  [15:0] in,
    input         load,
    output [15:0] out
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_bit
            n2t_bit u_bit(.clk(clk), .in(in[i]), .load(load), .out(out[i]));
        end
    endgenerate
endmodule
