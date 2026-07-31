`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module HalfAdder_wave_tb;

    reg  [0:0] a = 1'h0;
    reg  [0:0] b = 1'h0;
    wire [0:0] sum;
    wire [0:0] carry;

    n2t_half_adder dut(
        .a(a),
        .b(b),
        .sum(sum),
        .carry(carry)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, a, b, sum, carry);

        a = 1'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        b = 1'h0;
        #10;
        a = 1'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        b = 1'h1;
        #10;
        a = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        b = 1'h0;
        #10;
        a = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        b = 1'h1;
        #10;
        #10;
        $finish;
    end
endmodule