`timescale 1ns/1ps

// FullAdder：三个输入的全加器，由两个半加器 + 或门构成
// 对应 nand2tetris Project 2 的 FullAdder.hdl
module n2t_full_adder (
    input  a,
    input  b,
    input  c,
    output sum,
    output carry
);
    wire s1, c1, c2;
    n2t_half_adder u1(.a(a), .b(b), .sum(s1), .carry(c1));
    n2t_half_adder u2(.a(s1), .b(c), .sum(sum), .carry(c2));
    n2t_or u_or(.a(c1), .b(c2), .out(carry));
endmodule
