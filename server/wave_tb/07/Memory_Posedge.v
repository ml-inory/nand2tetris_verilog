`timescale 1ns/1ps

// 波形演示激励（手工 testbench 自动生成）：只驱动端口、只 dump 端口。
module Memory_Posedge_wave_tb;

    reg clk = 1'b0;
    reg  [15:0] in = 16'h0;
    reg  [0:0] load = 1'h0;
    reg  [14:0] address = 15'h0;
    reg  [15:0] keyboard_in = 16'h0;
    reg  [0:0] dbg_we = 1'h0;
    reg  [13:0] dbg_addr = 14'h0;
    reg  [15:0] dbg_wdata = 16'h0;
    wire [15:0] out;

    n2t_memory_posedge dut(
        .clk(clk),
        .in(in),
        .load(load),
        .address(address),
        .keyboard_in(keyboard_in),
        .dbg_we(dbg_we),
        .dbg_addr(dbg_addr),
        .dbg_wdata(dbg_wdata),
        .out(out)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, in, load, address, keyboard_in, dbg_we, dbg_addr, dbg_wdata, out);

        // 简单激励：先复位两拍，再载入数据，最后再跑两拍
        #5;
        #10;
        in = 16'h3;
        load = 1'h1;
        address = 15'h3;
        keyboard_in = 16'h3;
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