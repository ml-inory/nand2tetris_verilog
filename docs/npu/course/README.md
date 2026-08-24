# NPU 扩展课程资料

模仿 nand2tetris.org 的资料组织方式，每章提供 3 个 PDF：

- **Project.pdf**：作业指南（背景、目标、交付物、验收契约、提示）
- **Lecture.pdf**：PPT 风格讲义（A4 横版），面向零基础读者：
  按高中生起点讲解：二进制、内存、CPU、矩阵、神经网络、MMIO 全部从零开始，
  大量生活类比 + 矢量配图 + 论文引用，末尾附术语速查与延伸阅读
- **Assignment.pdf**：习题集（书面推导 + 提交清单 + 评分表）

## 章节

| Chapter | 主题 | Project | Lecture | Assignment |
| --- | --- | --- | --- | --- |
| 0 | 预备知识：从二进制到矩阵 | [Project.pdf](Chapter00/Project.pdf) | [Lecture.pdf](Chapter00/Lecture.pdf) | [Assignment.pdf](Chapter00/Assignment.pdf) |
| 1 | NPU 与系统架构 | [Project.pdf](Chapter01/Project.pdf) | [Lecture.pdf](Chapter01/Lecture.pdf) | [Assignment.pdf](Chapter01/Assignment.pdf) |
| 2 | PE 与脉动阵列 | [Project.pdf](Chapter02/Project.pdf) | [Lecture.pdf](Chapter02/Lecture.pdf) | [Assignment.pdf](Chapter02/Assignment.pdf) |
| 3 | GEMM 控制器与卷积数据通路 | [Project.pdf](Chapter03/Project.pdf) | [Lecture.pdf](Chapter03/Lecture.pdf) | [Assignment.pdf](Chapter03/Assignment.pdf) |
| 4 | 模型训练与量化导出 | [Project.pdf](Chapter04/Project.pdf) | [Lecture.pdf](Chapter04/Lecture.pdf) | [Assignment.pdf](Chapter04/Assignment.pdf) |
| 5 | 整机集成与端到端推理 | [Project.pdf](Chapter05/Project.pdf) | [Lecture.pdf](Chapter05/Lecture.pdf) | [Assignment.pdf](Chapter05/Assignment.pdf) |

## 重新生成

PDF 由 [tools/gen_npu_pdfs.py](../../../tools/gen_npu_pdfs.py) 生成，需要 reportlab：

```bash
python3 -m venv /tmp/pdfenv
/tmp/pdfenv/bin/pip install reportlab
/tmp/pdfenv/bin/python tools/gen_npu_pdfs.py          # 全部章节
/tmp/pdfenv/bin/python tools/gen_npu_pdfs.py 2 4      # 只生成第 2、4 章
# 也可以用 Makefile（PDF_PY 指向带 reportlab 的 python）：
# make pdf-npu PDF_PY=/tmp/pdfenv/bin/python
```

章节数量和主题可以随时在脚本顶部的 `CHAPTERS` 列表里调整。

## 与仓库的对应关系

| Chapter | 仓库对应内容 |
| --- | --- |
| 0 | 预备知识：概念自测与手算练习（无代码） |
| 1 | 设计文档 + `n2t_npu_top` 端口草案（未实现） |
| 2 | `assignment/06`：ShiftRegister、PE 与 SystolicArray（已搭好框架） |
| 3 | 后续 `assignment/07`：控制器、激活/池化、FC |
| 4 | 后续 `tools/npu_mnist.py` 与 `npu_data/` |
| 5 | `solution/07` posedge Hack 整机 + NPU 的 MMIO 集成 |
