`timescale 1ns/1ps

// ROM32K：32K x 16 只读存储器，存放 Hack 机器码
// 课程里用内置 ROM32K + load 命令加载 .hack 文件；
// 这里用 $readmemb 直接读二进制 .hack 文件（通过参数 INIT_FILE 指定）。
// 对应 nand2tetris Project 5 的 ROM32K
module n2t_rom32k #(
    parameter INIT_FILE = ""   // 二进制 .hack 文件（可选）
) (
    input  [14:0] address,
    output [15:0] out
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
