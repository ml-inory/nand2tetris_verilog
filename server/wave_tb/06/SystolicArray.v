`timescale 1ns/1ps

// 波形演示激励（手工 testbench 自动生成）：只驱动端口、只 dump 端口。
module SystolicArray_wave_tb;

    reg clk = 1'b0;
    reg  [0:0] rst = 1'h0;
    reg  [0:0] w_load = 1'h0;
    reg  [511:0] w_data = 512'h0;
    reg  [63:0] a_data = 64'h0;
    wire [255:0] psum_out;

    n2t_systolic_array dut(
        .clk(clk),
        .rst(rst),
        .w_load(w_load),
        .w_data(w_data),
        .a_data(a_data),
        .psum_out(psum_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, rst, w_load, w_data, a_data, psum_out);

        // 同步复位风格：先复位两拍，释放后再装载权重并跑两拍
        rst = 1;
        repeat (2) @(posedge clk);
        rst = 0;
        #1;
        w_load = 1'h1;
        w_data = 512'h3;
        a_data = 64'h3;
        @(posedge clk);
        #1;
        w_load = 0;
        @(posedge clk);
        #1;
        @(posedge clk);
        #1;
        $finish;
    end
endmodule