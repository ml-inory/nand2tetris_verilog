`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module Register_wave_tb;

    reg clk = 1'b0;
    reg  [15:0] in = 16'h0;
    reg  [0:0] load = 1'h0;
    wire [15:0] out;

    n2t_register dut(
        .clk(clk),
        .in(in),
        .load(load),
        .out(out)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, in, load, out);

        in = 16'h0;
        load = 1'h0;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        in = 16'h0;
        load = 1'h1;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        in = 16'h8285;
        load = 1'h0;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        in = 16'h2b67;
        load = 1'h0;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        #10;
        $finish;
    end
endmodule