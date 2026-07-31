`timescale 1ns/1ps

// RAM8：8 个 16 位寄存器，DMux8Way 译码写使能，Mux8Way16 读
// 对应 nand2tetris Project 3 的 RAM8.hdl
module n2t_ram8 (
    input         clk,
    input  [15:0] in,
    input         load,
    input  [2:0]  address,
    output [15:0] out
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
