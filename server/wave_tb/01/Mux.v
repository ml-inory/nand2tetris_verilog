`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module Mux_wave_tb;

    reg  [0:0] a = 1'h0;
    reg  [0:0] b = 1'h0;
    reg  [0:0] sel = 1'h0;
    wire [0:0] out;

    n2t_mux dut(
        .a(a),
        .b(b),
        .sel(sel),
        .out(out)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, a, b, sel, out);

        a = 1'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        b = 1'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        sel = 1'h0;
        #10;
        sel = 1'h1;
        #10;
        a = 1'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        b = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        sel = 1'h0;
        #10;
        sel = 1'h1;
        #10;
        a = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        b = 1'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        sel = 1'h0;
        #10;
        #10;
        $finish;
    end
endmodule