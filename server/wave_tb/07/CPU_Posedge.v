`timescale 1ns/1ps

// 波形演示激励（手工 testbench 自动生成）：只驱动端口、只 dump 端口。
module CPU_Posedge_wave_tb;

    reg clk = 1'b0;
    reg  [15:0] inM = 16'h0;
    reg  [15:0] instruction = 16'h0;
    reg  [0:0] reset = 1'h0;
    wire [15:0] outM;
    wire [0:0] writeM;
    wire [14:0] addressM;
    wire [14:0] pc;

    n2t_cpu_posedge dut(
        .clk(clk),
        .inM(inM),
        .instruction(instruction),
        .reset(reset),
        .outM(outM),
        .writeM(writeM),
        .addressM(addressM),
        .pc(pc)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, inM, instruction, reset, outM, writeM, addressM, pc);

        // 简单激励：先复位两拍，再载入数据，最后再跑两拍
        #5;
        #10;
        inM = 16'h3;
        instruction = 16'h3;
        reset = 1'h1;
        #10;
        clk = 1;
        #10;
        clk = 0;
        #10;
        #10;
        clk = 1;
        #10;
        $finish;
    end
endmodule