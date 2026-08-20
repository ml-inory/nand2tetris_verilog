`timescale 1ns/1ps

// 波形演示激励（手工 testbench 自动生成）：只驱动端口、只 dump 端口。
module SystolicArray_wave_tb;

    reg clk = 1'b0;
    reg  [0:0] arst = 1'h0;
    reg  [0:0] w_load = 1'h0;
    reg  [511:0] w_data = 512'h0;
    reg  [63:0] a_data = 64'h0;
    wire [255:0] psum_out;

    n2t_systolic_array dut(
        .clk(clk),
        .arst(arst),
        .w_load(w_load),
        .w_data(w_data),
        .a_data(a_data),
        .psum_out(psum_out)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, arst, w_load, w_data, a_data, psum_out);

        // 简单激励：先复位两拍，再载入数据，最后再跑两拍
        #5;
        arst = 1;
        #10;
        w_load = 1'h1;
        w_data = 512'h3;
        a_data = 64'h3;
        #10;
        clk = 1;
        #10;
        clk = 0;
        #10;
        arst = 0;
        w_load = 0;
        #10;
        clk = 1;
        #10;
        $finish;
    end
endmodule