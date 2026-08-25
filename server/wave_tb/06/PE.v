`timescale 1ns/1ps

// 波形演示激励：与 tb/06/PE_tb.v 的判题序列保持一致
module PE_wave_tb;
    reg clk = 1'b0;
    reg arst = 1'b1;
    reg w_load = 1'b0;
    reg signed [7:0] w_in = 8'sd0;
    reg signed [7:0] a_in = 8'sd0;
    reg signed [31:0] psum_in = 32'sd0;
    wire signed [7:0] w_out, a_out;
    wire signed [31:0] psum_out;

    n2t_pe dut(
        .clk(clk), .arst(arst), .w_load(w_load),
        .w_in(w_in), .a_in(a_in), .psum_in(psum_in),
        .w_out(w_out), .a_out(a_out), .psum_out(psum_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, arst, w_load, w_in, a_in, psum_in, w_out, a_out, psum_out);
        repeat (2) @(posedge clk);   // 复位两拍
        arst = 0; #1;
        w_load = 1; w_in = 8'sd5; a_in = 8'sd0; psum_in = 32'sd0;
        @(posedge clk); #1;
        w_load = 0;
        a_in = 8'sd7;
        @(posedge clk); #1;
        a_in = -8'sd3; psum_in = 32'sd35;
        @(posedge clk); #1;
        arst = 1;
        @(posedge clk); #1;
        $finish;
    end
endmodule
