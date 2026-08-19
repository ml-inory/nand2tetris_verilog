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
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
