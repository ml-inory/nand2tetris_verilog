`timescale 1ns/1ps

// ROM32K：32K x 16 只读存储器，存放 Hack 机器码
// 课程里用内置 ROM32K + load 命令加载 .hack 文件；
// 这里用 $readmemb 直接读二进制 .hack 文件（通过参数 INIT_FILE 指定）。
// 对应 nand2tetris Project 5 的 ROM32K
module n2t_rom32k #(
    parameter INIT_FILE = ""   // 二进制 .hack 文件（可选）
) (
    input  [14:0] address,
    output [15:0] out
);
    reg [15:0] mem [0:32767];
    integer i;

    initial begin
        for (i = 0; i < 32768; i = i + 1) mem[i] = 16'h0000;
        if (INIT_FILE != "") $readmemb(INIT_FILE, mem);
    end

    assign out = mem[address];
endmodule
