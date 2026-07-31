`timescale 1ns/1ps

// CPU：Hack CPU，包含 A/D 寄存器、ALU 与程序计数器 PC
// 对应 nand2tetris Project 5 的 CPU.hdl
//
// 时序模型与官方硬件模拟器逐拍一致（参考 nand2tetris 官方实现）：
//   tick（上升沿）：
//     - D 寄存器采样 ALU 结果（用更新前的 D/A 计算）
//     - outM 更新为 tick 时刻的 ALU 结果；writeM 为组合输出
//     - 暂存 tick 时刻的 ALU 结果与标志位（供 tock 使用）
//   tock（下降沿）：
//     - A 寄存器、PC 提交
//     - outM 用“更新后的 D + 新 A”重算并提交（与官方一致）
//   DRegister[] 探针读到的是 tick 时刻采样的 D 值（与官方测试一致）
module n2t_cpu (
    input         clk,
    input  [15:0] inM,
    input  [15:0] instruction,
    input         reset,
    output reg [15:0] outM,
    output        writeM,
    output [14:0] addressM,
    output [14:0] pc
);
    // 测试台按层级路径读取 cpu.a_reg / cpu.d_reg / cpu.pc_reg，
    // 请保留这三个寄存器命名（对应课程中的 ARegister / DRegister / PC）。
    reg [15:0] a_reg;
    reg [15:0] d_reg;
    reg [14:0] pc_reg;

    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
