`timescale 1ns/1ps

// Mux（2 选 1）：sel=0 时 out=a，sel=1 时 out=b
// 对应 nand2tetris Project 1 的 Mux.hdl
module n2t_mux (
    input  a,
    input  b,
    input  sel,
    output out
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
