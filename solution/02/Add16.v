`timescale 1ns/1ps

// Add16：16 位行波进位加法器
// 对应 nand2tetris Project 2 的 Add16.hdl
module n2t_add16 (
    input  [15:0] a,
    input  [15:0] b,
    output [15:0] out
);
    wire [15:0] carry;
    n2t_full_adder u0(.a(a[0]), .b(b[0]), .c(1'b0), .sum(out[0]), .carry(carry[0]));
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : gen_add
            n2t_full_adder u_fa(
                .a(a[i]), .b(b[i]), .c(carry[i-1]),
                .sum(out[i]), .carry(carry[i])
            );
        end
    endgenerate
endmodule
