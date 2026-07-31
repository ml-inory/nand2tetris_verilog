`timescale 1ns/1ps

// DMux（1 分 2）：sel=0 时 in→a，sel=1 时 in→b
// 对应 nand2tetris Project 1 的 DMux.hdl
module n2t_dmux (
    input  in,
    input  sel,
    output a,
    output b
);
    wire nsel;
    n2t_not u_not(.in(sel), .out(nsel));
    n2t_and u_and_a(.a(in), .b(nsel), .out(a));
    n2t_and u_and_b(.a(in), .b(sel), .out(b));
endmodule
