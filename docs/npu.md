# Project 6：NPU 脉动阵列（自定义扩展）

## 目标

在现有 nand2tetris Hack 整机之外，从零搭一个可综合的 NPU 学习工程：

1. 实现 int8 weight-stationary 脉动阵列（PE -> N×N SystolicArray）；
2. 扩展出卷积/激活/池化/全连接数据通路；
3. 用 PyTorch 训练并量化一个小 MNIST 分类模型，导出权重与 golden；
4. 在仿真中端到端分类一张图；
5. 可选：作为 MMIO 外设挂进 `n2t_computer`，用 Hack 机器码发起推理。

最终目标是让现有 Verilog 作业链具备“CPU + NPU”的完整形态，为更大的模型
（如 tiny YOLO）预留架构空间。

## 当前进度（框架已搭好）

```text
solution/06/PE.v             单 PE：int8 x int8 + int32 累加
solution/06/SystolicArray.v  参数化 N x N weight-stationary 脉动阵列
assignment/06/               学生作业模板（实现留空）
tb/06/PE_tb.v                PE 单元测试
tb/06/SystolicArray_tb.v     8x8 阵列矩阵乘测试
```

运行：

```bash
make sim-06 RTLDIR=solution   # 答案回归
make sim-06                   # 学生模式（需要先补全模板）
```

官方 Hack（Project 5）为对齐官方测试向量使用 negedge；为了让 NPU 与 Hack
能在同一个 posedge 下集成，仓库新增 `solution/07/`（posedge 版 CPU /
RAM16K / Memory / Computer），功能等价且 `make sim-07` 已通过 Add/Max 验证。
这套模块是 NPU 集成的**已知库**，不作为作业发布。

## 课程资料（每章 3 个 PDF）

模仿 nand2tetris.org 的资料形式，每章提供 Project / Lecture / Assignment
三个 PDF，覆盖从系统设计到端到端推理的完整路线：

```text
docs/npu/course/
├── Chapter00/  预备知识：从二进制到矩阵（高中起点）
├── Chapter01/  NPU 与系统架构
├── Chapter02/  PE 与脉动阵列（当前 assignment/06）
├── Chapter03/  GEMM 控制器与卷积数据通路
├── Chapter04/  模型训练与量化导出
└── Chapter05/  整机集成与端到端推理
```

索引与生成方法见 [`docs/npu/course/README.md`](course/README.md)。
Lecture 讲义已扩展为“高中生也能看懂”的版本：第 0 章从二进制、内存、
CPU、矩阵、神经网络、卷积、MMIO 讲起；后面每章都配有生活类比、详细讲解、
矢量配图、论文引用、术语速查和延伸阅读。

## 数据布局与时序

阵列计算的是：

```text
C[k][col] = sum_{row=0..N-1} A[row][k] * W[row][col]
```

对应到卷积 GEMM：

- `A` 的行 = 输入通道，列 = 空间位置（像素）
- `W` 的行 = 输入通道，列 = 输出通道
- `C` 的每一拍 = 一个空间位置上所有输出通道的结果

端口约定（扁平向量，行主序）：

| 端口 | 含义 |
| --- | --- |
| `w_data` | `N*N*W_W` 位，`w_data[row*N+col] = W[row][col]` |
| `a_data` | `N*A_W` 位，第 k 拍送 `A[*][k]` |
| `psum_out` | `N*P_W` 位，最后一个输入送入后再等 `N-1` 拍，开始逐拍输出 |

阵列内部把第 `row` 行的输入延迟 `row` 拍（斜输入），所以外部**不需要**自己打 skew。
底部还会按列做输出对齐，消除经典脉动阵列的斜输出。权重用 `w_load` 批量装载，
装载完成后再开始送 `a_data`。

Project 06（NPU 扩展）使用正规上升沿（posedge）提交，与真实 FPGA 一致；
复位采用同步复位（rst 高电平时在 posedge 清零），避免 reset/clk 竞争；
Hack 官方部分（Project 1/2/3/5）仍使用 negedge，以对齐官方测试向量。

## 作业要求

1. 阅读 `docs/npu.md` 与 `solution/06/` 的注释；
2. 补全 `assignment/06/PE.v` 与 `assignment/06/SystolicArray.v`；
3. 跑 `make sim-06`，全部 PASS 即通过。

实现提示：

- PE 内部要有一个权重寄存器，`w_load` 时写入；
- 乘法必须是有符号乘法，累加位宽 `P_W`（默认 32）足够容纳 8×8×int8×int8；
- 阵列里“行 i 延迟 i 拍”和“psum 逐行下移”是脉动时序正确性的关键。

## 后续里程碑

```text
[x] PE + 8x8 SystolicArray + 测试台
[ ] 权重/输入 SRAM + GEMM 控制器
[ ] 卷积数据通路（padding/stride/im2col 或 line buffer）
[ ] ReLU / MaxPool / 全连接
[ ] Python：训练 MNIST 小模型 -> int8 量化 -> 导出 hex + golden
[ ] 端到端分类仿真
[ ] MMIO 挂进 Hack Computer（地址段 0x7000+）+ Hack 驱动
[ ] 评估是否扩展 tiny YOLO
```

## 验证约定

手工 testbench 统一输出：

```text
PASS: all checks ok (total N)
FAIL: M errors out of N checks
```

在线判题站已为 `PE` / `SystolicArray` 登记题库条目，`tb/06/*_tb.v` 是手工维护的，
`make tb` 不会覆盖它们。
