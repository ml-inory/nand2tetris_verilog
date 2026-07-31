`timescale 1ns/1ps

// RAM512：512 x 16
// 课程里由 8 个 RAM64 拼成；这里用扁平存储阵列实现，
// 避免仿真器把层级 RAM 展开成数十万触发器（贴近真实 RTL 的 BRAM 推断）。
// 对应 nand2tetris Project 3 的 RAM512.hdl
module n2t_ram512 (
    input         clk,
    input  [15:0] in,
    input         load,
    input  [8:0]  address,
    output [15:0] out
);
    reg [15:0] mem [0:511];
    integer i;
    initial begin
        for (i = 0; i < 512; i = i + 1) mem[i] = 16'h0000;
    end
    always @(negedge clk) begin
        if (load) mem[address] <= in;
    end
    assign out = mem[address];
endmodule
