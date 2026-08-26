`timescale 1ns/1ps

// ShiftRegister：参数化移位寄存器。
//
// 用途：
//   - 脉动阵列的“斜输入”：第 row 行延迟 row 拍；
//   - 脉动阵列的“输出对齐”：第 col 列延迟 N-1-col 拍。
//
// 行为：
//   en=1 时，每个 clk 上升沿把 in 移入第 0 级，旧数据依次右移；
//   out 是最后一级的输出（延迟 DEPTH 拍）。
//   arst 为异步复位（高有效），复位后所有级清零。
//   必须支持 DEPTH=0（直通）：脉动阵列第 0 行和最后一列需要 0 拍延迟。
module n2t_shift_register #(
    parameter W       = 8,   // 数据位宽
    parameter DEPTH   = 4,   // 寄存器级数（延迟拍数）
    parameter RESET_VAL = 0  // 复位值
) (
    input  clk,
    input  arst,             // async reset（异步复位，高有效）
    input  en,               // 移位使能
    input  [W-1:0] in,
    output [W-1:0] out
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 docs/npu.md 与 solution/06/ 的完整实现。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-06 RTLDIR=assignment` 验证。

endmodule
