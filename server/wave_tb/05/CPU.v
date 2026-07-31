`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module CPU_wave_tb;

    reg clk = 1'b0;
    reg  [15:0] inM = 16'h0;
    reg  [15:0] instruction = 16'h0;
    reg  [0:0] reset = 1'h0;
    wire [15:0] outM;
    wire [0:0] writeM;
    wire [14:0] addressM;
    wire [14:0] pc;

    n2t_cpu cpu(
        .clk(clk),
        .inM(inM),
        .instruction(instruction),
        .reset(reset),
        .outM(outM),
        .writeM(writeM),
        .addressM(addressM),
        .pc(pc)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, inM, instruction, reset, outM, writeM, addressM, pc);

        instruction = 16'h3039;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        instruction = 16'hec10;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        instruction = 16'h5ba0;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        instruction = 16'he1d0;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        instruction = 16'h3e8;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        instruction = 16'he308;
        #10;
        $finish;
    end
endmodule