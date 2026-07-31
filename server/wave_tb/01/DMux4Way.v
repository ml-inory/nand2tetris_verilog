`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module DMux4Way_wave_tb;

    reg  [0:0] in = 1'h0;
    reg  [1:0] sel = 2'h0;
    wire [0:0] a;
    wire [0:0] b;
    wire [0:0] c;
    wire [0:0] d;

    n2t_dmux4way dut(
        .in(in),
        .sel(sel),
        .a(a),
        .b(b),
        .c(c),
        .d(d)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, in, sel, a, b, c, d);

        in = 1'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        sel = 2'h0;
        #10;
        sel = 2'h1;
        #10;
        sel = 2'h2;
        #10;
        sel = 2'h3;
        #10;
        in = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        sel = 2'h0;
        #10;
        sel = 2'h1;
        #10;
        sel = 2'h2;
        #10;
        #10;
        $finish;
    end
endmodule