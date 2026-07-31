`timescale 1ns/1ps

// Xor：out = a ^ b = (a & ~b) | (~a & b)
// 对应 nand2tetris Project 1 的 Xor.hdl
module n2t_xor (
    input  a,
    input  b,
    output out
);
    wire na, nb, ab_, a_b;
    n2t_not u_not_a(.in(a), .out(na));
    n2t_not u_not_b(.in(b), .out(nb));
    n2t_and u_and_ab(.a(a), .b(nb), .out(ab_));
    n2t_and u_and_a_b(.a(na), .b(b), .out(a_b));
    n2t_or  u_or(.a(ab_), .b(a_b), .out(out));
endmodule
