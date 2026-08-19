`timescale 1ns/1ps

// RAM16K（posedge 版）：16K x 16 主内存
// 功能与官方 n2t_ram16k 相同，但改为正规上升沿（posedge）提交，
// 供 NPU 集成使用；官方测试版本保持 negedge 不变。
module n2t_ram16k_posedge #(
    parameter INIT_FILE = ""
) (
    input         clk,
    input  [15:0] in,
    input         load,
    input  [14:0] address,
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

    always @(posedge clk) begin
        if (load) mem[address[13:0]] <= in;
    end

    always @* begin
        if (dbg_we) mem[dbg_addr] = dbg_wdata;
    end

    assign out = mem[address[13:0]];
endmodule
