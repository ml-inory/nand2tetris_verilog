`timescale 1ns/1ps

// RAM64：8 个 RAM8，address[5:3] 译码，address[2:0] 片内寻址
// 对应 nand2tetris Project 3 的 RAM64.hdl
module n2t_ram64 (
    input         clk,
    input  [15:0] in,
    input         load,
    input  [5:0]  address,
    output [15:0] out
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
