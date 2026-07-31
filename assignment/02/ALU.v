`timescale 1ns/1ps

// ALU：Hack 芯片的核心算术逻辑单元，按课程方式用门级/部件级搭建
// 对应 nand2tetris Project 2 的 ALU.hdl
//
// 功能：
//   zx: x 置 0       nx: x 取反     zy: y 置 0
//   ny: y 取反       f: 1=加 0=与   no: 输出取反
//   zr: out==0       ng: out<0（最高位）
module n2t_alu (
    input  [15:0] x,
    input  [15:0] y,
    input         zx,
    input         nx,
    input         zy,
    input         ny,
    input         f,
    input         no,
    output [15:0] out,
    output        zr,
    output        ng
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
