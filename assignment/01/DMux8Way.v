`timescale 1ns/1ps

// DMux8Way：1 分 8，sel[2] 为高位
// 对应 nand2tetris Project 1 的 DMux8Way.hdl
module n2t_dmux8way (
    input  in,
    input  [2:0] sel,
    output a,
    output b,
    output c,
    output d,
    output e,
    output f,
    output g,
    output h
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
