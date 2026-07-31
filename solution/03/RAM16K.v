`timescale 1ns/1ps

// RAM16K：16K x 16 主内存
// 课程里由 4 个 RAM4K 拼成；这里用扁平存储阵列实现，
// 更接近真实 RTL（综合工具会把它推断为 Block RAM），
// 并通过参数 INIT_FILE / 背板写口支持测试预置。
// 对应 nand2tetris Project 3 的 RAM16K.hdl
module n2t_ram16k #(
    parameter INIT_FILE = ""   // 十六进制初始化文件（可选，仅仿真用）
) (
    input         clk,
    input  [15:0] in,
    input         load,
    input  [14:0] address,     // 与课程一致：address[14] 未使用
    // 测试背板写口（仅仿真，综合时忽略）
    input         dbg_we,
    input  [13:0] dbg_addr,
    input  [15:0] dbg_wdata,
    output [15:0] out
);
    reg [15:0] mem [0:16383];
    integer i;

    initial begin
        for (i = 0; i < 16384; i = i + 1) mem[i] = 16'h0000;
        if (INIT_FILE != "") $readmemh(INIT_FILE, mem);
    end

    always @(negedge clk) begin
        if (load) mem[address[13:0]] <= in;
    end

    // 背板写：组合写入，不需要时钟沿，仅用于测试预置 RAM 内容
    always @* begin
        if (dbg_we) mem[dbg_addr] = dbg_wdata;
    end

    assign out = mem[address[13:0]];
endmodule
