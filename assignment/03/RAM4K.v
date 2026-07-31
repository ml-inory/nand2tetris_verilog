`timescale 1ns/1ps

// RAM4K：4096 x 16
// 课程里由 8 个 RAM512 拼成；这里用扁平存储阵列实现，
// 避免仿真器把层级 RAM 展开成数十万触发器（贴近真实 RTL 的 BRAM 推断）。
// 对应 nand2tetris Project 3 的 RAM4K.hdl
module n2t_ram4k (
    input         clk,
    input  [15:0] in,
    input         load,
    input  [11:0] address,
    output [15:0] out
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
