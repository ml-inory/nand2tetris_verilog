`timescale 1ns/1ps

// MaxPool 2x2：从 2x2 窗口（4 个 int8 值）取最大值。
//
// stride=2 时输出宽高减半；纯组合逻辑，只需要比较器，不占用乘法器，
// 可以跟在卷积输出后面流式处理。
module n2t_maxpool #(
    parameter A_W = 8   // 数据位宽（有符号）
) (
    input  signed [A_W-1:0] in0,
    input  signed [A_W-1:0] in1,
    input  signed [A_W-1:0] in2,
    input  signed [A_W-1:0] in3,
    output reg signed [A_W-1:0] out
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 docs/npu/course/Chapter03/ 与 solution/07/ 的完整实现。
    // 完成后执行 `make sim-07 RTLDIR=assignment` 验证。

endmodule
