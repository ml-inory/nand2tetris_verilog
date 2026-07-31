`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module ALU_wave_tb;

    reg  [15:0] x = 16'h0;
    reg  [15:0] y = 16'h0;
    reg  [0:0] zx = 1'h0;
    reg  [0:0] nx = 1'h0;
    reg  [0:0] zy = 1'h0;
    reg  [0:0] ny = 1'h0;
    reg  [0:0] f = 1'h0;
    reg  [0:0] no = 1'h0;
    wire [15:0] out;
    wire [0:0] zr;
    wire [0:0] ng;

    n2t_alu dut(
        .x(x),
        .y(y),
        .zx(zx),
        .nx(nx),
        .zy(zy),
        .ny(ny),
        .f(f),
        .no(no),
        .out(out),
        .zr(zr),
        .ng(ng)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, x, y, zx, nx, zy, ny, f, no, out, zr, ng);

        x = 16'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        y = 16'hffff;
        #10;   // 组合电路：让每个输入步在波形里可见
        zx = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        nx = 1'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        zy = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        ny = 1'h0;
        #10;   // 组合电路：让每个输入步在波形里可见
        f = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        no = 1'h0;
        #10;
        zx = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        nx = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        zy = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        ny = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        f = 1'h1;
        #10;   // 组合电路：让每个输入步在波形里可见
        no = 1'h1;
        #10;
        #10;
        $finish;
    end
endmodule