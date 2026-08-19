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
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
