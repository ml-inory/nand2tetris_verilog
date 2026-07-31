`timescale 1ns/1ps

// Mux16：16 位 2 选 1，sel 共用
// 对应 nand2tetris Project 1 的 Mux16.hdl
module n2t_mux16 (
    input  [15:0] a,
    input  [15:0] b,
    input         sel,
    output [15:0] out
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
