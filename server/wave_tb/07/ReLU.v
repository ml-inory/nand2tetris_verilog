`timescale 1ns/1ps

// 波形演示激励：ReLU 斜坡输入 -4..3。
module ReLU_wave_tb;
    reg [7:0] in = 0;
    wire [7:0] out;
    integer k;

    n2t_relu dut(
        .in(in), .out(out)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, in, out);
        for (k = -4; k <= 3; k = k + 1) begin
            in = k[7:0];
            #10;
        end
        $finish;
    end
endmodule
