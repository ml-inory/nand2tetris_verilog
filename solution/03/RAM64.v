`timescale 1ns/1ps

// RAM64：64 x 16
// 课程里由 8 个 RAM8 拼成；这里用扁平存储阵列实现，
// 避免被更大 RAM（如 RAM512 例化 8 个 RAM64）展开成数十万触发器
// 导致编译/仿真资源爆炸（贴近真实 RTL 的 BRAM 推断）。
// 对应 nand2tetris Project 3 的 RAM64.hdl
module n2t_ram64 (
    input         clk,
    input  [15:0] in,
    input         load,
    input  [5:0]  address,
    output [15:0] out
);
    reg [15:0] mem [0:63];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1) mem[i] = 16'h0000;
    end

    always @(negedge clk) begin
        if (load) mem[address] <= in;
    end

    assign out = mem[address];
endmodule
