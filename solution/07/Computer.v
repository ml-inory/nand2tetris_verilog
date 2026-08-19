`timescale 1ns/1ps

// Computer（posedge 版）：ROM32K + CPU(posedge) + Memory(posedge)
// 与官方 n2t_computer 端口一致，全部时序逻辑使用上升沿，
// 供 NPU 以同一边沿集成。
module n2t_computer_posedge #(
    parameter ROM_INIT_FILE = "",
    parameter RAM_INIT_FILE = ""
) (
    input  clk,
    input  reset,
    output [15:0] outM,
    output        writeM,
    output [14:0] addressM,
    output [14:0] pc,
    input         dbg_we,
    input  [13:0] dbg_addr,
    input  [15:0] dbg_wdata
);
    wire [15:0] instr, inM;

    n2t_rom32k #(.INIT_FILE(ROM_INIT_FILE)) u_rom(
        .address(pc), .out(instr)
    );

    n2t_cpu_posedge u_cpu(
        .clk(clk), .inM(inM), .instruction(instr), .reset(reset),
        .outM(outM), .writeM(writeM), .addressM(addressM), .pc(pc)
    );

    n2t_memory_posedge #(.RAM_INIT_FILE(RAM_INIT_FILE)) u_mem(
        .clk(clk), .in(outM), .load(writeM), .address(addressM),
        .keyboard_in(16'h0000),
        .dbg_we(dbg_we), .dbg_addr(dbg_addr), .dbg_wdata(dbg_wdata),
        .out(inM)
    );
endmodule
