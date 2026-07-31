`timescale 1ns/1ps

// PC：16 位程序计数器（带 load/inc/reset），由 Mux16 + Inc16 + Register 构成
// 优先级：reset > load > inc > 保持；状态在下降沿提交（与课程模拟器一致）
// 对应 nand2tetris Project 3 的 PC.hdl
module n2t_pc (
    input         clk,
    input  [15:0] in,
    input         load,
    input         inc,
    input         reset,
    output [15:0] out
);
    wire [15:0] inc_out, m_inc, m_load, m_reset;

    n2t_inc16   u_inc(.in(out), .out(inc_out));
    n2t_mux16   u_inc_mux(.a(out), .b(inc_out), .sel(inc), .out(m_inc));
    n2t_mux16   u_load_mux(.a(m_inc), .b(in), .sel(load), .out(m_load));
    n2t_mux16   u_reset_mux(.a(m_load), .b(16'h0000), .sel(reset), .out(m_reset));
    n2t_register u_reg(.clk(clk), .in(m_reset), .load(1'b1), .out(out));
endmodule
