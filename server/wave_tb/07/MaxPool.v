`timescale 1ns/1ps

// 波形演示激励：MaxPool 三组 2x2 窗口。
module MaxPool_wave_tb;
    reg [7:0] in0 = 0, in1 = 0, in2 = 0, in3 = 0;
    wire [7:0] out;

    n2t_maxpool dut(
        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .out(out)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, in0, in1, in2, in3, out);
        {in0, in1, in2, in3} = {8'sd1, 8'sd2, 8'sd3, 8'sd4}; #10;
        {in0, in1, in2, in3} = {-8'sd5, -8'sd1, -8'sd9, 8'sd0}; #10;
        {in0, in1, in2, in3} = {-8'sd2, -8'sd3, -8'sd4, -8'sd1}; #10;
        $finish;
    end
endmodule
