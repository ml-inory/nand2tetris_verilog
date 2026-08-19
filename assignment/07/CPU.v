`timescale 1ns/1ps

// CPU（posedge 版）：与官方 Hack CPU 功能等价的单边沿实现。
//
// 设计说明：
//   - D / A / PC 全部在 clk 上升沿提交；
//   - outM / writeM / addressM 为组合输出；
//   - 上升沿到来前，outM 是“tick 值”（用旧 D/A 计算），
//     上升沿之后自动变成“tock 值”（用新 D/A 计算）；
//   - Memory 在同一上升沿写入时看到的是上升沿前的 outM，
//     因此内存写入语义与官方版本一致（M 写入 tick 时刻的 ALU 结果）。
//
// 官方 Hack 测试版本（solution/05）保持 negedge 不变，以对齐 .tst/.cmp；
// 本模块供 NPU 集成使用，时钟与 NPU 统一为 posedge。
module n2t_cpu_posedge (
    input         clk,
    input  [15:0] inM,
    input  [15:0] instruction,
    input         reset,
    output [15:0] outM,
    output        writeM,
    output [14:0] addressM,
    output [14:0] pc
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
