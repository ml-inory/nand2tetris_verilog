`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module Bit_wave_tb;

    reg clk = 1'b0;
    reg  [0:0] in = 1'h0;
    reg  [0:0] load = 1'h0;
    wire [0:0] out;

    n2t_bit dut(
        .clk(clk),
        .in(in),
        .load(load),
        .out(out)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, in, load, out);

        in = 1'h0;
        load = 1'h0;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        in = 1'h0;
        load = 1'h1;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        in = 1'h1;
        load = 1'h0;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        in = 1'h1;
        load = 1'h1;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        #10;
        $finish;
    end
endmodule