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
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
