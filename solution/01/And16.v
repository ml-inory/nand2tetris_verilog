`timescale 1ns/1ps

// And16：16 位按位与
// 对应 nand2tetris Project 1 的 And16.hdl
module n2t_and16 (
    input  [15:0] a,
    input  [15:0] b,
    output [15:0] out
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_and
            n2t_and u_and(.a(a[i]), .b(b[i]), .out(out[i]));
        end
    endgenerate
endmodule
