`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module Not16_wave_tb;

    reg  [15:0] in = 16'h0;
    wire [15:0] out;

    n2t_not16 dut(
        .in(in),
        .out(out)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, in, out);

        in = 16'h0;
        #10;
        in = 16'hffff;
        #10;
        in = 16'haaaa;
        #10;
        in = 16'h3cc3;
        #10;
        in = 16'h1234;
        #10;
        #10;
        $finish;
    end
endmodule