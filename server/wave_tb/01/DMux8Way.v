`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module DMux8Way_wave_tb;

    reg  [0:0] in = 1'h0;
    reg  [2:0] sel = 3'h0;
    wire [0:0] a;
    wire [0:0] b;
    wire [0:0] c;
    wire [0:0] d;
    wire [0:0] e;
    wire [0:0] f;
    wire [0:0] g;
    wire [0:0] h;

    n2t_dmux8way dut(
        .in(in),
        .sel(sel),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .h(h)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, in, sel, a, b, c, d, e, f, g, h);

        in = 1'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        sel = 3'h0;
        #10;
        sel = 3'h1;
        #10;
        sel = 3'h2;
        #10;
        sel = 3'h3;
        #10;
        sel = 3'h4;
        #10;
        sel = 3'h5;
        #10;
        sel = 3'h6;
        #10;
        sel = 3'h7;
        #10;
        $finish;
    end
endmodule