`timescale 1ns/1ps

// 波形演示激励（手工 testbench 自动生成）：只驱动端口、只 dump 端口。
module ShiftRegister_wave_tb;

    reg clk = 1'b0;
    reg  [0:0] arst = 1'h0;
    reg  [0:0] en = 1'h0;
    reg  [7:0] in = 8'h0;
    wire [7:0] out;

    n2t_shift_register dut(
        .clk(clk),
        .arst(arst),
        .en(en),
        .in(in),
        .out(out)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, arst, en, in, out);

        // 简单激励：先复位两拍，再载入数据，最后再跑两拍
        #5;
        arst = 1;
        #10;
        en = 1'h1;
        in = 8'h3;
        #10;
        clk = 1;
        #10;
        clk = 0;
        #10;
        arst = 0;
        #10;
        clk = 1;
        #10;
        $finish;
    end
endmodule