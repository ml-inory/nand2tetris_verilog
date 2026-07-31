`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module Or8Way_wave_tb;

    reg  [7:0] in = 8'h0;
    wire [0:0] out;

    n2t_or8way dut(
        .in(in),
        .out(out)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, in, out);

        in = 8'h0;
        #10;
        in = 8'hff;
        #10;
        in = 8'h10;
        #10;
        in = 8'h1;
        #10;
        in = 8'h26;
        #10;
        #10;
        $finish;
    end
endmodule