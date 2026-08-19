`timescale 1ns/1ps

// 波形演示激励（手工 testbench 自动生成）：只驱动端口、只 dump 端口。
module ComputerPosedge_wave_tb;

    reg clk = 1'b0;
    reg  [0:0] reset = 1'h0;
    wire [15:0] outM;
    wire [0:0] writeM;
    wire [14:0] addressM;
    wire [14:0] pc;
    reg  [0:0] dbg_we = 1'h0;
    reg  [13:0] dbg_addr = 14'h0;
    reg  [15:0] dbg_wdata = 16'h0;

    n2t_computer_posedge dut(
        .clk(clk),
        .reset(reset),
        .outM(outM),
        .writeM(writeM),
        .addressM(addressM),
        .pc(pc),
        .dbg_we(dbg_we),
        .dbg_addr(dbg_addr),
        .dbg_wdata(dbg_wdata)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, reset, outM, writeM, addressM, pc, dbg_we, dbg_addr, dbg_wdata);

        // 简单激励：先复位两拍，再载入数据，最后再跑两拍
        #5;
        #10;
        reset = 1'h1;
        dbg_we = 1'h1;
        dbg_addr = 14'h3;
        dbg_wdata = 16'h3;
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