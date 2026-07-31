`timescale 1ns/1ps

// Bit：1 位数据位。
// 课程硬件模拟器在 tick（时钟 0->1）采样输入、tock（1->0）提交输出，
// 官方测试向量也是“tick 后看旧值、tock 后看新值”。
// 为与官方向量逐行一致，这里在下降沿提交（真实 FPGA 一般用上升沿，
// 想改成 posedge 的话需要同步调整测试台的采样点）。
// 对应 nand2tetris Project 3 的 Bit.hdl
module n2t_bit (
    input  clk,
    input  in,
    input  load,
    output reg out
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
