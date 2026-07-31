`timescale 1ns/1ps

// Or16：16 位按位或
// 对应 nand2tetris Project 1 的 Or16.hdl
module n2t_or16 (
    input  [15:0] a,
    input  [15:0] b,
    output [15:0] out
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_or
            n2t_or u_or(.a(a[i]), .b(b[i]), .out(out[i]));
        end
    endgenerate
endmodule
