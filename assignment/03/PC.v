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
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
