`timescale 1ns/1ps

// 波形演示激励：与 tb/06/SystolicArray_tb.v 的判题序列保持一致
module SystolicArray_wave_tb;
    reg clk = 1'b0;
    reg arst = 1'b1;
    reg w_load = 1'b0;
    reg [511:0] w_data = 0;
    reg [63:0] a_data = 0;
    wire [255:0] psum_out;
    integer k;

    n2t_systolic_array dut(
        .clk(clk), .arst(arst), .w_load(w_load),
        .w_data(w_data), .a_data(a_data), .psum_out(psum_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, arst, w_load, w_data, a_data, psum_out);
        repeat (2) @(posedge clk);   // 复位两拍
        arst = 0; #1;
        w_load = 1;
        w_data = 512'h0101010101010101010101010101010101010101010101010101010101010101;
        @(posedge clk); #1;
        w_load = 0;
        for (k = 0; k < 8; k = k + 1) begin
            a_data = 64'h0102030405060708;
            @(posedge clk); #1;
        end
        repeat (7) @(posedge clk);   // 流水排空
        #1;
        $finish;
    end
endmodule
