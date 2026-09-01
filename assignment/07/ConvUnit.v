`timescale 1ns/1ps

// ConvUnit：3x3 卷积 + 量化域 ReLU 的完整数据通路，复用 N x N 脉动阵列。
//
// 计算语义（int8）：
//   out[oy][ox][oc] = relu_clamp( sum_{ky,kx,ic}
//        ifmap[oy*STRIDE+ky-PAD][ox*STRIDE+kx-PAD][ic] * W[oc][ic][ky][kx] )
//   其中 iy/ix 越界按 0 补齐；relu_clamp(x) = (x<0) ? 0 : (x>127 ? 127 : x)
//
// 阵列复用方式（tap 外循环 + 通道 tiling）：
//   3x3xC_IN 的 im2col 行长度 9*C_IN > 阵列宽度 C_IN，按 (ky,kx) 拆成 9 个 tap；
//   每个 tap 是一次“C_IN 输入通道 x C_OUT 输出通道”的 GEMM，外部 int32
//   累加器把 9 个 tap 的部分和累加成一个输出像素的所有输出通道。
//   权重矩阵 W[oc][ic][ky][kx] 扁平化：w_data[((oc*C_IN+ic)*K*K+ky*K+kx)*W_W +: W_W]
//
// 状态机（控制器与数据通路分离）：
//   IDLE -> LOAD_W -> RUN -> DRAIN -> EMIT -> DONE
//     IDLE   等待 start（wr_ifmap=1 期间逐拍装载特征图）
//     LOAD_W 把第 tap 个 C_IN x C_OUT 权重矩阵写入阵列
//     RUN    逐拍送输入向量并收集输出（注意阵列延迟与流水排空）
//     DRAIN  等本 tap 全部结果收完
//     EMIT   逐拍输出 relu_clamp 后的像素（out_valid=1）
//     DONE   done 脉冲一拍，回 IDLE
//
// 端口约定：
//   - ifmap_in 每拍一个像素的 C_IN 个通道，wr_ifmap=1 时写入内部缓冲；
//   - w_data 为扁平权重，启动（start）时整体写入内部权重缓冲；
//   - out_data 一拍一个输出像素的 C_OUT 个通道，out_valid 指示有效；
//   - done 整幅图推理完成。
module n2t_conv_unit #(
    parameter H      = 8,   // 输入特征图高（本框架取 8）
    parameter W      = 8,   // 输入特征图宽（本框架取 8）
    // 注意：框架默认 C_IN=C_OUT=4（阵列 N=4），把参数调成 8 即复用 8x8
    // 阵列，逻辑不变；8x8 在 iverilog 里逐拍仿真开销较大，故默认取 4。
    parameter C_IN   = 4,   // 输入通道（须等于阵列 N）
    parameter C_OUT  = 4,   // 输出通道（须等于阵列 N）
    parameter K      = 3,   // 卷积核尺寸
    parameter STRIDE = 1,   // 1 或 2
    parameter PAD    = 0,   // 0 或 1
    parameter A_W    = 8,   // 激活位宽（有符号）
    parameter W_W    = 8,   // 权重位宽（有符号）
    parameter P_W    = 32   // 累加位宽（有符号）
) (
    input  clk,
    input  arst,                                // async reset（高有效）
    input  wr_ifmap,                            // 装载特征图：每拍写一个像素
    input  [C_IN*A_W-1:0] ifmap_in,             // 一个像素的 C_IN 个通道
    input  [C_OUT*C_IN*K*K*W_W-1:0] w_data,     // 扁平权重
    input  start,                               // 特征图装载完成后启动一次推理
    output reg [C_OUT*A_W-1:0] out_data,        // 一拍一个输出像素的 C_OUT 个通道
    output reg out_valid,                       // out_data 有效
    output reg done                             // 整幅图推理完成（脉冲一拍）
);
    // ==================== 作业：请补全本模块实现 ====================
    // 提示：
    //   1. 例化 solution/06 的 n2t_systolic_array（N=C_IN）作为计算核心；
    //   2. 阵列从输入到对齐输出固定延迟 LAT = 2*(N-1) 拍，RUN 开始后
    //      前 LAT 拍 psum_out 为 0，之后每拍一个有效向量；
    //   3. 相邻 tap 之间需要冲掉流水（送 2*(N-1) 个 0 并等排空），
    //      否则上一 tap 残留在阵列里的激活会污染下一 tap；
    //   4. 参考 docs/npu/course/Chapter03/ 与 solution/07/ 的完整实现。
    // 完成后执行 `make sim-07 RTLDIR=assignment` 验证。

endmodule
