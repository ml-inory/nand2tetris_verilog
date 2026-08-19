`timescale 1ns/1ps

// Memory（posedge 版）：Hack 完整地址空间（RAM16K + Screen + Keyboard）
// 与官方 n2t_memory 功能相同，但 RAM/Screen 统一在上升沿提交，
// 供 NPU 集成使用。
module n2t_memory_posedge #(
    parameter RAM_INIT_FILE = ""
) (
    input         clk,
    input  [15:0] in,
    input         load,
    input  [14:0] address,
    input  [15:0] keyboard_in,
    input         dbg_we,
    input  [13:0] dbg_addr,
    input  [15:0] dbg_wdata,
    output [15:0] out
);
    wire load_ram    = load & ~address[14];
    wire load_screen = load &  address[14] & ~address[13];

    wire [15:0] ram_out, screen_out;

    n2t_ram16k_posedge #(.INIT_FILE(RAM_INIT_FILE)) u_ram(
        .clk(clk), .in(in), .load(load_ram), .address(address),
        .dbg_we(dbg_we), .dbg_addr(dbg_addr), .dbg_wdata(dbg_wdata),
        .out(ram_out)
    );

    reg [15:0] screen [0:8191];
    integer i;
    initial begin
        for (i = 0; i < 8192; i = i + 1) screen[i] = 16'h0000;
    end
    always @(posedge clk) begin
        if (load_screen) screen[address[12:0]] <= in;
    end
    assign screen_out = screen[address[12:0]];

    assign out = address[14] ? (address[13] ? keyboard_in : screen_out) : ram_out;
endmodule
