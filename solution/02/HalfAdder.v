`timescale 1ns/1ps

// HalfAdder：sum = a^b, carry = a&b
// 对应 nand2tetris Project 2 的 HalfAdder.hdl
module n2t_half_adder (
    input  a,
    input  b,
    output sum,
    output carry
);
    n2t_xor u_xor(.a(a), .b(b), .out(sum));
    n2t_and u_and(.a(a), .b(b), .out(carry));
endmodule
