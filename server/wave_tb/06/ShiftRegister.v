`timescale 1ns/1ps

// 波形演示激励：与 tb/06/ShiftRegister_tb.v 的判题序列保持一致
module ShiftRegister_wave_tb;
    reg clk = 1'b0;
    reg arst = 1'b1;
    reg en = 1'b1;
    reg [7:0] in = 8'h0;
    wire [7:0] out;

    n2t_shift_register #(.W(8), .DEPTH(4)) dut(
        .clk(clk), .arst(arst), .en(en), .in(in), .out(out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, arst, en, in, out);
        repeat (2) @(posedge clk);   // 复位两拍
        arst = 0; #1;
        in = 8'h01; @(posedge clk); #1;
        in = 8'h02; @(posedge clk); #1;
        in = 8'h03; @(posedge clk); #1;
        in = 8'h04; @(posedge clk); #1;
        in = 8'h05; @(posedge clk); #1;
        en = 0; in = 8'hff; @(posedge clk); #1;
        en = 1; arst = 1; @(posedge clk); #1;
        $finish;
    end
endmodule
