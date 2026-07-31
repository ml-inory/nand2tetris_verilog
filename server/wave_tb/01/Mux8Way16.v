`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module Mux8Way16_wave_tb;

    reg  [15:0] a = 16'h0;
    reg  [15:0] b = 16'h0;
    reg  [15:0] c = 16'h0;
    reg  [15:0] d = 16'h0;
    reg  [15:0] e = 16'h0;
    reg  [15:0] f = 16'h0;
    reg  [15:0] g = 16'h0;
    reg  [15:0] h = 16'h0;
    reg  [2:0] sel = 3'h0;
    wire [15:0] out;

    n2t_mux8way16 dut(
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .h(h),
        .sel(sel),
        .out(out)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, a, b, c, d, e, f, g, h, sel, out);

        a = 16'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        b = 16'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        c = 16'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        d = 16'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        e = 16'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        f = 16'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        g = 16'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        h = 16'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        sel = 3'h0;
        #10;
        sel = 3'h1;
        #10;
        sel = 3'h2;
        #10;
        sel = 3'h3;
        #10;
        #10;
        $finish;
    end
endmodule