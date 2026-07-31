`timescale 1ns/1ps

// Mux（2 选 1）：sel=0 时 out=a，sel=1 时 out=b
// 对应 nand2tetris Project 1 的 Mux.hdl
module n2t_mux (
    input  a,
    input  b,
    input  sel,
    output out
);
    wire nsel, ta, tb;
    n2t_not u_not(.in(sel), .out(nsel));
    n2t_and u_and_a(.a(a), .b(nsel), .out(ta));
    n2t_and u_and_b(.a(b), .b(sel), .out(tb));
    n2t_or  u_or(.a(ta), .b(tb), .out(out));
endmodule
