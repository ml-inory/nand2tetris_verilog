# nand2tetris_verilog

把 nand2tetris 课程 **Hardware 部分（Project 1/2/3/5）的 assignment 用 Verilog 重写**，并配套
自动化测试工具链：官方 `.tst/.cmp` 测试向量会被自动翻译成 Verilog testbench，直接跑
`iverilog` 即可逐行比对，得到与课程硬件模拟器一致的 PASS/FAIL 结果。

在官方 Project 5 之外，仓库还包含一个自定义 **Project 6（NPU 脉动阵列）** 扩展：
从单 PE 到 N×N 脉动阵列，逐步往“内存映射 NPU + 小模型推理”的目标搭。
项目面向"更接近实战"的学习体验：RTL 结构式、可综合风格、贴近真实硬件（扁平存储阵列、
显式时钟端口、参数化 ROM/RAM 初始化、测试背板写口），同时严格保持课程官方的行为语义。

## 目录结构

```
solution/        完整答案（Project 1/2/3/5 + 自定义 Project 6 起步，全部实现）
assignment/      学生作业模板（模块端口声明保留、实现留空，待补全）
tools/tst2tb.py  .tst/.cmp -> Verilog testbench 自动翻译器
tools/gen_assignment.py  从 solution 重新生成 assignment 作业模板
ref/             官方测试向量（.tst + .cmp）
programs/        Hack 机器码示例（Add.hack / Max.hack / Rect.hack）
tb/0X/           生成的 testbench（+ 手工 tb/05/Memory_tb.v）
sim/             仿真输出（vvp 二进制、VCD 波形）
Makefile         一键仿真 / 测试 / 波形 / 生成作业
docs/npu.md      Project 6（NPU 脉动阵列）设计与路线图
```

## 在线练习（server 分支）

仓库的 `server` 分支附带一个类似 [HDLBits](https://hdlbits.01xz.net/) 的在线判题小站：
浏览器里写 Verilog，服务端用 iverilog 跑官方 testbench 实时判分，支持波形可视化
（WaveDrom）、进度统计、测试台查看与最近判题。

```bash
git checkout server          # 切到在线判题分支
python3 server/gen_problems.py
docker build -f server/Dockerfile -t n2t-server .
docker run --rm -p 8000:8000 n2t-server
```

详见 [`server/README.md`](server/README.md)（架构、本地运行、Docker 部署、安全边界）。

## 环境要求

- **iverilog**（>= 12.0，支持 `-g2012`）
- **gtkwave**（可选，看波形用）
- Python 3（仅用于重新生成 testbench）

本机没有系统 iverilog 时，可以用 deb 包免安装解包到本地目录使用：

```bash
apt-get download iverilog
dpkg -x iverilog_*.deb /tmp/iverilog-local
ln -sfn lib/x86_64-linux-gnu /tmp/iverilog-local/usr/x86_64-linux-gnu
export PATH=/tmp/iverilog-local/usr/bin:$PATH
```

## 快速开始

```bash
make test                 # 用 solution（答案）全量回归：01 + 02 + 03 + 05 + 06
make sim-03               # 验证作业 Project 3（默认用 assignment）
make sim-02                   # 验证作业 Project 2（默认用 assignment）
make sim-06                   # 验证 NPU Project 6（PE + SystolicArray）
make wave CHIP=ALU        # 生成波形并用 gtkwave 打开（也可手动打开 sim/ALU_tb.vcd）
make tb                   # 用 tools/tst2tb.py 重新生成全部 testbench
make assign               # 从 solution 重新生成 assignment 作业模板
make clean                # 清掉 sim/
```

`make test` 会为每个芯片编译并运行一个 testbench，输出形如：

```
== ALU_tb ==
PASS: all checks ok (total 80)
All projects simulated.
```

## 与课程的差异（重要）

课程硬件模拟器把芯片"引脚"当黑盒，且时序语义是 **tick 采样、tock 提交**；Verilog 是
事件驱动语言，二者不能 1:1 直接映射。本项目的处理方式：

1. **时钟显式化**：每个时序模块都有 `clk` 端口，官方模拟器隐藏的 tick/tock 在这里就是
   时钟的两个沿。为保证与官方 `.tst` 逐拍一致，时序逻辑统一在 **negedge 提交**
   （真实 FPGA 用 posedge 时，只需同步调整 testbench 的采样点，RTL 逻辑不变）。
2. **模块命名加 `n2t_` 前缀**：`and/or/not/xor` 是 Verilog 关键字，直接叫 `And.v` 会冲突；
   加前缀后文件名与课程一一对应（`solution/01/And.v` 内是 `module n2t_and`）。
3. **CPU 时序特例**：官方 CPU 在 tick 采样 D（测试探针读到的就是 tick 时刻的值）、
   tock 提交 A/PC；`outM` 是寄存输出，tick 用旧值算、tock 用"新 D + 新 A"重算提交。
   实现里用两个 ALU 实例（`u_alu_tick` / `u_alu_tock`）分别对应两个时刻，逐拍对齐官方测试。
4. **RAM 扁平化**：RAM512/4K/16K 用扁平存储阵列（`reg [15:0] mem [0:N-1]`）而非课程里的
   层级拼装，否则 iverilog 会把层级 RAM 展开成数十万触发器（RAM4K 曾吃掉 4.6GB 内存）。
   这也是真实 RTL 的做法——综合工具会把它推断成 Block RAM。
5. **测试背板写口 `dbg_*`**：官方 `.tst` 能直接 `set RAM16K[i]` 预置内存，而 RTL 内存
   没有这样的引脚，所以 `RAM16K/Memory/Computer` 增加了仅仿真用的组合写口
   `dbg_we/dbg_addr/dbg_wdata`（综合时忽略）。
6. **键盘输入端口**：官方 Memory 的键盘映射地址是内置输入设备；这里把它做成显式输入
   `keyboard_in`，真实 SoC 中可接到键盘控制器。
7. **ROM 加载 .hack**：`ROM32K` 用参数 `INIT_FILE` + `$readmemb` 直接加载二进制机器码
   （`programs/Add.hack` 等），替代课程的 ROM load 命令；RAM 也可用 `$readmemh` 预置。

## 测试向量与练习方法

`ref/` 下的 `.tst/.cmp` 来自 nand2tetris 官方课程配套仓库的镜像（本项目使用的版本
保留了完整测试向量与版权声明，仅供学习使用）。`tools/tst2tb.py` 支持 `set/eval/
tick/tock/output/repeat`、`%B/%D/%X` 格式、don't-care `*******`、背板写和层级探针
（如 `ARegister[]`、`RAM16K[0]`）。

**练习流程**：`assignment/` 里的作业文件只保留了端口声明，实现部分留空。把对应
Project 的作业做完后，直接跑仿真验证（默认就使用 `assignment/`）：

```bash
# 例如完成 Project 2（加法器 / ALU）
# 编辑 assignment/02/ 下的 .v 文件，补全实现
make sim-02              # 全部 PASS 即通过
```

作业文件可以自由改成结构式（例化更小的 `n2t_*` 模块）或行为式写法；如果改乱了，
`make assign` 会从 `solution/` 重新生成一份干净的作业模板（注意会覆盖当前改动）。

### Project 5 的命名契约

官方 `CPU.tst` / `Computer*.tst` 会用层级探针读取内部寄存器与内存（对应课程里的
`ARegister[]` / `DRegister[]` / `PC[]` / `RAM16K[]`），因此 `assignment/05/` 的模板
保留了一小部分"骨架"，其余逻辑仍然留空：

- `CPU.v`：保留 `a_reg` / `d_reg` / `pc_reg` 三个寄存器声明（对应课程部件名
  `ARegister` / `DRegister` / `PC`），测试台按 `cpu.d_reg` 等路径读取；
- `RAM16K.v`：保留 `mem` 存储数组声明，测试台按 `u_comp.u_mem.u_ram.mem[i]` 读取；
- `Memory.v`：保留 `n2t_ram16k` 的例化 `u_ram`，地址译码、Screen/Keyboard、输出选择留空；
- `Computer.v`：保留 `u_rom` / `u_cpu` / `u_mem` 三块部件的接线骨架（Computer 本身只是
  简单接线，作业重点是 CPU 与 Memory 的逻辑）。

学生实现时**必须保留这些命名**，否则测试台无法按层级路径绑定信号（这是课程官方
测试脚本本身的要求）。其余项目（01/02/03）没有内部探针，实现完全自由。

## 验证矩阵

| Project | 内容 | 芯片数 | 说明 |
| ------- | ---- | ---- | ---- |
| 1 | 基本逻辑门 | 16 | 全部由 `n2t_nand` 结构搭建（Nand 为原语，无独立测试向量） |
| 2 | 加法器与 ALU | 5 | ALU 用 mux16/not16/and16/add16 组合 |
| 3 | 时序电路 | 8 | Bit/Register/RAM 系列/PC |
| 5 | 整机 | 4+1 | CPU、Memory、Computer + ROM32K；Computer 跑通 Add/Max/Rect |
| 6 | NPU 脉动阵列（自定义） | 2+ | PE、N×N SystolicArray；后续扩展 Conv/Act/Pool/MMIO |

## Project 6（自定义 NPU 扩展）

这是仓库自带的进阶作业，不属于官方 nand2tetris 课程，目标是：

1. 实现 int8 脉动阵列（weight-stationary）；
2. 扩展成卷积/池化/全连接数据通路；
3. 用 Python 训练并量化一个小的 MNIST 分类模型；
4. 最终在仿真中完成一张图片的端到端分类推理；
5. 可选：通过 MMIO 挂进现有 Hack Computer，用 Hack 机器码发起推理。

目前已完成第一步的作业框架：

- `solution/06/PE.v`：单 PE（int8×int8 + int32 累加）
- `solution/06/SystolicArray.v`：参数化 N×N 脉动阵列
- `assignment/06/`：对应作业模板
- `tb/06/`：PE 与阵列的独立测试台

```bash
make sim-06 RTLDIR=solution   # 用答案验证
make sim-06                   # 学生模式（模板留空，需要补全）
```

详细的数据布局、时序约定与后续里程碑见 [`docs/npu.md`](docs/npu.md)。
每章的 Project / Lecture / Assignment 三个 PDF 见
[`docs/npu/course/`](docs/npu/course/README.md)。
