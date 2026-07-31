`timescale 1ns/1ps

// Or8Way：8 输入或门（树形）
// 对应 nand2tetris Project 1 的 Or8Way.hdl
module n2t_or8way (
    input  [7:0] in,
    output       out
);
    wire o1, o2, o3, o4, o5, o6;
    n2t_or u1(.a(in[0]), .b(in[1]), .out(o1));
    n2t_or u2(.a(in[2]), .b(in[3]), .out(o2));
    n2t_or u3(.a(in[4]), .b(in[5]), .out(o3));
    n2t_or u4(.a(in[6]), .b(in[7]), .out(o4));
    n2t_or u5(.a(o1), .b(o2), .out(o5));
    n2t_or u6(.a(o3), .b(o4), .out(o6));
    n2t_or u7(.a(o5), .b(o6), .out(out));
endmodule
