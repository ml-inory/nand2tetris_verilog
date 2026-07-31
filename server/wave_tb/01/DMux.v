`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module DMux_wave_tb;

    reg  [0:0] in = 1'h0;
    reg  [0:0] sel = 1'h0;
    wire [0:0] a;
    wire [0:0] b;

    n2t_dmux dut(
        .in(in),
        .sel(sel),
        .a(a),
        .b(b)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, in, sel, a, b);

        in = 1'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        sel = 1'h0;
        #10;
        sel = 1'h1;
        #10;
        in = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        sel = 1'h0;
        #10;
        sel = 1'h1;
        #10;
        #10;
        $finish;
    end
endmodule