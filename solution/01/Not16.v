`timescale 1ns/1ps

// Not16：16 位按位取反
// 对应 nand2tetris Project 1 的 Not16.hdl
module n2t_not16 (
    input  [15:0] in,
    output [15:0] out
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_not
            n2t_not u_not(.in(in[i]), .out(out[i]));
        end
    endgenerate
endmodule
