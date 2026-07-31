`timescale 1ns/1ps

// Or：out = a | b，由 Not + Nand 构成
// 对应 nand2tetris Project 1 的 Or.hdl
module n2t_or (
    input  a,
    input  b,
    output out
);
    wire na, nb;
    n2t_not  u_not_a(.in(a), .out(na));
    n2t_not  u_not_b(.in(b), .out(nb));
    n2t_nand u_nand(.a(na), .b(nb), .out(out));
endmodule
