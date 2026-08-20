`timescale 1ns/1ps

// 波形演示激励（手工 testbench 自动生成）：只驱动端口、只 dump 端口。
module PE_wave_tb;

    reg clk = 1'b0;
    reg  [0:0] rst = 1'h0;
    reg  [0:0] w_load = 1'h0;
    reg  [7:0] w_in = 8'h0;
    reg  [7:0] a_in = 8'h0;
    reg  [31:0] psum_in = 32'h0;
    wire [7:0] w_out;
    wire [7:0] a_out;
    wire [31:0] psum_out;

    n2t_pe dut(
        .clk(clk),
        .rst(rst),
        .w_load(w_load),
        .w_in(w_in),
        .a_in(a_in),
        .psum_in(psum_in),
        .w_out(w_out),
        .a_out(a_out),
        .psum_out(psum_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, rst, w_load, w_in, a_in, psum_in, w_out, a_out, psum_out);

        // 同步复位风格：先复位两拍，释放后再装载权重并跑两拍
        rst = 1;
        repeat (2) @(posedge clk);
        rst = 0;
        #1;
        w_load = 1'h1;
        w_in = 8'h3;
        a_in = 8'h3;
        psum_in = 32'h3;
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