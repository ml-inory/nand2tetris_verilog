`timescale 1ns/1ps

// Memory：Hack 完整地址空间（RAM16K + Screen + Keyboard）
// 对应 nand2tetris Project 5 的 Memory.hdl
//   address 0x0000-0x3FFF -> RAM16K
//   address 0x4000-0x5FFF -> Screen（8K 字）
//   address 0x6000        -> Keyboard（只读）
module n2t_memory #(
    parameter RAM_INIT_FILE = ""   // RAM 初始化文件（可选，仅仿真用）
) (
    input         clk,
    input  [15:0] in,
    input         load,
    input  [14:0] address,
    input  [15:0] keyboard_in,     // 键盘映射输入（真实 SoC 中来自键盘控制器）
    // 测试背板写口（透传给 RAM16K）
    input         dbg_we,
    input  [13:0] dbg_addr,
    input  [15:0] dbg_wdata,
    output [15:0] out
);
    wire load_ram    = load & ~address[14];
    wire load_screen = load &  address[14] & ~address[13];

    wire [15:0] ram_out, screen_out;

    n2t_ram16k #(.INIT_FILE(RAM_INIT_FILE)) u_ram(
        .clk(clk), .in(in), .load(load_ram), .address(address),
        .dbg_we(dbg_we), .dbg_addr(dbg_addr), .dbg_wdata(dbg_wdata),
        .out(ram_out)
    );

    // Screen：8K 字，同步写、组合读
    reg [15:0] screen [0:8191];
    integer i;
    initial begin
        for (i = 0; i < 8192; i = i + 1) screen[i] = 16'h0000;
    end
    always @(negedge clk) begin
        if (load_screen) screen[address[12:0]] <= in;
    end
    assign screen_out = screen[address[12:0]];

    assign out = address[14] ? (address[13] ? keyboard_in : screen_out) : ram_out;
endmodule
