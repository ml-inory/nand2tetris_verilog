`timescale 1ns/1ps

// ReLU（量化域）：out = max(in, 0)。
//
// 阵列累加结果是 int32；反量化并重新量化到 int8 后（本章 scale=1），
// ReLU 在量化域里只是负数清零，纯组合逻辑、零乘法。
module n2t_relu #(
    parameter A_W = 8   // 数据位宽（有符号）
) (
    input  signed [A_W-1:0] in,
    output reg signed [A_W-1:0] out
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 docs/npu/course/Chapter03/ 与 solution/07/ 的完整实现。
    // 完成后执行 `make sim-07 RTLDIR=assignment` 验证。

endmodule
