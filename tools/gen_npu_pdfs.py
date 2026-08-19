#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_npu_pdfs.py — 为 NPU 扩展生成“每章 3 个 PDF”的课程资料。

模仿 nand2tetris.org 的资料组织方式：
  每章包含 Project（作业指南）、Lecture（PPT 风格讲义）、Assignment（习题）。

用法：
    python3 tools/gen_npu_pdfs.py            # 生成全部章节
    python3 tools/gen_npu_pdfs.py 2 3        # 只生成第 2、3 章

输出：docs/npu/course/ChapterXX/{Project,Lecture,Assignment}.pdf
"""
import os
import sys

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.lib.utils import simpleSplit
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.cidfonts import UnicodeCIDFont
from reportlab.platypus import (
    PageBreak, Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle,
)

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
OUT_ROOT = os.path.join(ROOT, 'docs', 'npu', 'course')

FONT = 'STSong-Light'
ORANGE = colors.HexColor('#DD6B13')
DARK = colors.HexColor('#222222')
GRAY = colors.HexColor('#666666')
LIGHT = colors.HexColor('#F5F0E8')


def register_font():
    pdfmetrics.registerFont(UnicodeCIDFont(FONT))


def wrap_lines(text, font, size, max_w):
    """按字符宽度给中文/英文混排文本换行。"""
    out = []
    for raw in text.split('\n'):
        if not raw:
            out.append('')
            continue
        line = ''
        for ch in raw:
            if pdfmetrics.stringWidth(line + ch, font, size) > max_w and line:
                out.append(line)
                line = ch
            else:
                line += ch
        out.append(line)
    return out


def build_styles():
    s = getSampleStyleSheet()
    st = {}
    st['cover'] = ParagraphStyle('cover', parent=s['Title'], fontName=FONT,
                                 fontSize=30, leading=38, textColor=ORANGE,
                                 alignment=1, spaceAfter=18)
    st['cover_sub'] = ParagraphStyle('cover_sub', parent=s['Normal'],
                                     fontName=FONT, fontSize=16, leading=24,
                                     textColor=DARK, alignment=1, spaceAfter=6)
    st['cover_kind'] = ParagraphStyle('cover_kind', parent=s['Normal'],
                                      fontName=FONT, fontSize=20, leading=28,
                                      textColor=DARK, alignment=1,
                                      spaceBefore=20, spaceAfter=6)
    st['h1'] = ParagraphStyle('h1', parent=s['Heading1'], fontName=FONT,
                              fontSize=20, leading=26, textColor=ORANGE,
                              spaceBefore=12, spaceAfter=8)
    st['h2'] = ParagraphStyle('h2', parent=s['Heading2'], fontName=FONT,
                              fontSize=15, leading=20, textColor=DARK,
                              spaceBefore=10, spaceAfter=6)
    st['body'] = ParagraphStyle('body', parent=s['Normal'], fontName=FONT,
                                fontSize=11, leading=17, textColor=DARK,
                                spaceAfter=5)
    st['bullet'] = ParagraphStyle('bullet', parent=s['Normal'], fontName=FONT,
                                  fontSize=11, leading=17, textColor=DARK,
                                  leftIndent=16, bulletIndent=4, spaceAfter=4)
    st['q'] = ParagraphStyle('q', parent=s['Normal'], fontName=FONT,
                             fontSize=11.5, leading=18, textColor=DARK,
                             spaceBefore=8, spaceAfter=3)
    st['hint'] = ParagraphStyle('hint', parent=s['Normal'], fontName=FONT,
                                fontSize=10, leading=15, textColor=GRAY,
                                leftIndent=16, spaceAfter=8)
    st['slide_title'] = ParagraphStyle('slide_title', parent=s['Title'],
                                       fontName=FONT, fontSize=25, leading=32,
                                       textColor=ORANGE, alignment=0)
    st['slide_body'] = ParagraphStyle('slide_body', parent=s['Normal'],
                                      fontName=FONT, fontSize=15, leading=24,
                                      textColor=DARK, spaceAfter=8)
    st['slide_bullet'] = ParagraphStyle('slide_bullet', parent=s['Normal'],
                                        fontName=FONT, fontSize=14,
                                        leading=22, textColor=DARK,
                                        leftIndent=18, bulletIndent=4,
                                        spaceAfter=6)
    return st


def page_footer(ch, kind):
    def draw(canvas, doc):
        canvas.saveState()
        canvas.setFont(FONT, 8)
        canvas.setFillColor(GRAY)
        canvas.drawString(2 * cm, 1.1 * cm,
                          'Nand to Tetris / NPU Extension / Chapter %d / %s'
                          % (ch, kind))
        canvas.drawRightString(doc.pagesize[0] - 2 * cm, 1.1 * cm,
                               'Page %d' % canvas.getPageNumber())
        canvas.restoreState()
    return draw


def cover_flowables(st, ch, title, en_title, kind):
    return [
        Spacer(1, 2.5 * cm),
        Paragraph('From Nand to Tetris', st['cover_sub']),
        Paragraph('NPU Extension', st['cover_sub']),
        Spacer(1, 1.2 * cm),
        Paragraph('Chapter %d: %s' % (ch, title), st['cover']),
        Paragraph(en_title, st['cover_sub']),
        Spacer(1, 1.5 * cm),
        Paragraph(kind, st['cover_kind']),
        Spacer(1, 0.8 * cm),
        Paragraph('Building a Modern Computer From First Principles',
                  st['cover_sub']),
        PageBreak(),
    ]


def section(st, title, paras):
    out = [Paragraph(title, st['h1'])]
    for p in paras:
        out.append(Paragraph(p, st['body']))
    return out


def bullets(st, items):
    out = []
    for it in items:
        out.append(Paragraph('&bull;&nbsp; ' + it, st['bullet']))
    return out


def render_project(ch, meta, st):
    p = meta['project']
    path = os.path.join(OUT_ROOT, 'Chapter%02d' % ch, 'Project.pdf')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    doc = SimpleDocTemplate(path, pagesize=A4,
                            leftMargin=2.2 * cm, rightMargin=2.2 * cm,
                            topMargin=2.0 * cm, bottomMargin=1.8 * cm,
                            title='Chapter %d Project' % ch,
                            author='nand2tetris_verilog NPU Extension')
    story = cover_flowables(st, ch, meta['title'], meta['en_title'],
                            'Project')
    story += section(st, 'Background', p['background'])
    story += section(st, 'Objective', p['objective'])

    story.append(Paragraph('Deliverables', st['h1']))
    story += bullets(st, p['deliverables'])

    story.append(Paragraph('Contract', st['h1']))
    story += bullets(st, p['contract'])

    story.append(Paragraph('Resources', st['h1']))
    story += bullets(st, p['resources'])

    story.append(Paragraph('Tips', st['h1']))
    story += bullets(st, p['tips'])

    doc.build(story, onFirstPage=page_footer(ch, 'Project'),
              onLaterPages=page_footer(ch, 'Project'))
    print('generated %s' % os.path.relpath(path, ROOT))


def render_lecture(ch, meta, st):
    lec = meta['lecture']
    path = os.path.join(OUT_ROOT, 'Chapter%02d' % ch, 'Lecture.pdf')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    slides = lec['slides']
    total = len(slides)

    doc = SimpleDocTemplate(path, pagesize=landscape(A4),
                            leftMargin=1.8 * cm, rightMargin=1.8 * cm,
                            topMargin=3.0 * cm, bottomMargin=1.6 * cm,
                            title='Chapter %d Lecture' % ch,
                            author='nand2tetris_verilog NPU Extension')

    def footer(canvas, doc):
        canvas.saveState()
        canvas.setFont(FONT, 9)
        canvas.setFillColor(GRAY)
        canvas.drawString(1.8 * cm, 1.0 * cm,
                          'Nand to Tetris / NPU Extension / Chapter %d / Lecture'
                          % ch)
        canvas.drawRightString(doc.pagesize[0] - 1.8 * cm, 1.0 * cm,
                               'Slide %d/%d' % (doc.page, total))
        canvas.restoreState()

    def slide_bg(canvas, doc):
        canvas.saveState()
        w, h = doc.pagesize
        canvas.setStrokeColor(ORANGE)
        canvas.setLineWidth(2)
        canvas.line(1.8 * cm, h - 2.6 * cm, w - 1.8 * cm, h - 2.6 * cm)
        canvas.restoreState()

    story = []
    for i, slide in enumerate(slides):
        if i:
            story.append(PageBreak())
        story.append(Paragraph('Chapter %d &nbsp;|&nbsp; %s'
                               % (ch, slide['title']), st['slide_title']))
        story.append(Spacer(1, 0.5 * cm))
        for b in slide['bullets']:
            story.append(Paragraph('&bull;&nbsp; ' + b, st['slide_bullet']))
        if slide.get('note'):
            story.append(Spacer(1, 0.4 * cm))
            story.append(Paragraph('Note: ' + slide['note'], st['hint']))
    doc.build(story, onFirstPage=lambda c, d: (slide_bg(c, d), footer(c, d)),
              onLaterPages=lambda c, d: (slide_bg(c, d), footer(c, d)))
    print('generated %s' % os.path.relpath(path, ROOT))


def render_assignment(ch, meta, st):
    a = meta['assignment']
    path = os.path.join(OUT_ROOT, 'Chapter%02d' % ch, 'Assignment.pdf')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    doc = SimpleDocTemplate(path, pagesize=A4,
                            leftMargin=2.2 * cm, rightMargin=2.2 * cm,
                            topMargin=2.0 * cm, bottomMargin=1.8 * cm,
                            title='Chapter %d Assignment' % ch,
                            author='nand2tetris_verilog NPU Extension')
    story = cover_flowables(st, ch, meta['title'], meta['en_title'],
                            'Assignment')
    story.append(Paragraph('Introduction', st['h1']))
    story += [Paragraph(x, st['body']) for x in a['intro']]

    story.append(Paragraph('Questions', st['h1']))
    for i, item in enumerate(a['questions'], 1):
        story.append(Paragraph('Q%d. %s' % (i, item['q']), st['q']))
        if item.get('hint'):
            story.append(Paragraph('Hint: ' + item['hint'], st['hint']))

    story.append(Paragraph('What to Submit', st['h1']))
    story += bullets(st, a['submission'])

    story.append(Paragraph('Rubric', st['h1']))
    rows = [['Item', 'Points']]
    for name, pts in a['rubric']:
        rows.append([name, str(pts)])
    tbl = Table(rows, colWidths=[12.5 * cm, 2.5 * cm])
    tbl.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (-1, -1), FONT),
        ('BACKGROUND', (0, 0), (-1, 0), ORANGE),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#CCCCCC')),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, LIGHT]),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(tbl)
    story.append(Spacer(1, 0.5 * cm))
    story.append(Paragraph('Total: %d points' % sum(p for _, p in a['rubric']),
                           st['body']))
    doc.build(story, onFirstPage=page_footer(ch, 'Assignment'),
              onLaterPages=page_footer(ch, 'Assignment'))
    print('generated %s' % os.path.relpath(path, ROOT))


CHAPTERS = [
    {
        'num': 1,
        'title': 'NPU 与系统架构',
        'en_title': 'NPU and System Architecture',
        'project': {
            'background': [
                'Hack 计算机是一台 16 位、64KB RAM 的简单机器：ALU 只有加法和按位运算，没有乘法、没有浮点、没有向量指令。让 Hack CPU 直接执行 CNN 推理在计算量和存储量上都不现实。',
                '真实 SoC 的做法是在 CPU 旁边挂一个专用加速器（NPU）。CPU 只负责“下命令、查状态”，大量重复的乘累加由 NPU 完成。本课程的目标就是在 nand2tetris_verilog 项目里自己搭出这样一个 NPU，并最终跑通一个小分类模型。',
                '本章先不写实现，而是完成系统设计：确定 NPU 的内部结构、Hack 侧的 MMIO 接口、命令/状态寄存器协议，以及 int8 数据格式。',
            ],
            'objective': [
                '给出 NPU 的顶层架构图：CPU / Memory / NPU / SRAM 之间的关系。',
                '设计 Hack CPU 与 NPU 之间的内存映射接口（命令寄存器、状态寄存器、数据缓冲区）。',
                '定义 NPU 的命令描述符格式，并估算 8x8 int8 阵列的资源与吞吐量。',
            ],
            'deliverables': [
                '一份设计文档（Markdown 或 PDF），包含系统框图、数据流、寄存器表。',
                'NPU 顶层模块 `n2t_npu_top` 的端口草案（只声明端口，不需要实现）。',
                '一张 MMIO 地址分配表，建议使用 0x7000-0x7FFF 的未占用地址段。',
            ],
            'contract': [
                '设计文档必须覆盖：命令发起、数据写入、结果回读、完成轮询四个环节。',
                '端口草案必须与现有 `n2t_memory` / `n2t_computer` 的接线风格一致。',
                '所有寄存器必须有明确的位宽、方向（R/W）和复位值。',
            ],
            'resources': [
                '本仓库 `docs/npu.md`：当前路线图与已搭好的 PE / SystolicArray。',
                '`solution/05/Computer.v` 与 `solution/05/Memory.v`：Hack 整机接口。',
                'nand2tetris.org 的 Project 5：Computer Architecture，作为整机背景。',
            ],
            'tips': [
                '先设计“kick-off + poll”协议：CPU 写命令，NPU 执行，CPU 轮询完成位。',
                '把权重加载、图片输入、结果输出都看作“数据搬运”，不要一开始就混进计算细节。',
                'int8 是本章最重要的数据格式决策：激活和权重都按 8 位有符号整数存放，累加器用 32 位。',
            ],
        },
        'lecture': {
            'slides': [
                {'title': 'NPU 与系统架构', 'bullets': [
                    '本章目标：为 NPU 扩展确定系统级设计。',
                    '内容：为什么需要 NPU、系统分层、MMIO 协议、int8 数据格式。',
                    '产出：设计文档 + 顶层端口草案。',
                ]},
                {'title': '为什么 CPU 跑不动 CNN', 'bullets': [
                    'Hack ALU：16 位加法与按位运算，没有乘法。',
                    'RAM：32K x 16bit = 64KB，装不下 YOLO 权重。',
                    'CNN 推理的本质是大量重复的乘累加（MAC）。',
                    '结论：需要专用硬件做 GEMM。',
                ]},
                {'title': 'Von Neumann 瓶颈', 'bullets': [
                    '取指 -> 译码 -> 执行 -> 访存，每条指令都要搬数据。',
                    'MAC 运算密度高，指令流会成为瓶颈。',
                    'NPU 用数据流 + 局部 SRAM 降低搬运开销。',
                ]},
                {'title': '系统分层', 'bullets': [
                    'Hack CPU：调度器，发起推理、轮询状态。',
                    'Memory：保留原有 RAM/Screen/Keyboard，扩展 MMIO 段。',
                    'NPU：命令解析、DMA、脉动阵列、激活/池化。',
                    '数据路径：CPU -> Memory -> NPU SRAM -> Array -> 输出。',
                ]},
                {'title': 'NPU 内部结构', 'bullets': [
                    '命令寄存器：start、layer_id、src/dst 地址。',
                    '状态寄存器：busy、done、error。',
                    '权重 SRAM：保存 int8 权重。',
                    '输入/输出 SRAM：保存特征图。',
                    '脉动阵列：8x8 起步，完成矩阵乘。',
                ]},
                {'title': '为什么是 int8', 'bullets': [
                    '模型权重和激活用 8 位有符号整数表示。',
                    'int8 乘法面积小、速度快，适合 FPGA/ASIC。',
                    '累加器用 32 位，避免精度损失。',
                    '每层需要 scale 参数完成反量化。',
                ]},
                {'title': 'GEMM 是核心算子', 'bullets': [
                    '卷积可以转成矩阵乘：im2col。',
                    '全连接本来就是矩阵乘。',
                    '脉动阵列的目标：一个周期完成 N 个 MAC。',
                    '后续章节围绕“如何喂数据给阵列”展开。',
                ]},
                {'title': 'MMIO 协议', 'bullets': [
                    '地址 0x7000-0x7FFF 预留给 NPU。',
                    'CPU 写 CMD 寄存器启动推理。',
                    'CPU 读 STATUS 寄存器轮询完成。',
                    '数据缓冲区放在共享 RAM 或 NPU 私有 SRAM。',
                ]},
                {'title': '数据流总览', 'bullets': [
                    '图片 -> 输入 SRAM（或共享 RAM）。',
                    '权重 -> 权重 SRAM -> 脉动阵列。',
                    '阵列输出 -> 激活/池化 -> 输出 SRAM。',
                    '最终结果写回 Hack RAM，CPU 读取。',
                ]},
                {'title': '本章任务', 'bullets': [
                    '写系统设计文档。',
                    '画系统框图并标注数据流。',
                    '设计寄存器表与命令描述符。',
                    '给出 8x8 阵列的吞吐量估算。',
                ]},
                {'title': '路线图', 'bullets': [
                    'Ch2：PE 与 SystolicArray（已搭好框架）。',
                    'Ch3：GEMM 控制器与卷积数据通路。',
                    'Ch4：模型训练、量化与导出。',
                    'Ch5：Hack 整机集成与端到端推理。',
                ]},
                {'title': '总结', 'bullets': [
                    'NPU 的价值：把重复 MAC 从 CPU 卸载到专用硬件。',
                    'MMIO 是 CPU 与 NPU 之间的“合同”。',
                    'int8 + int32 累加是本课程统一的数值格式。',
                    '下一章从单个 PE 开始搭建阵列。',
                ]},
            ],
        },
        'assignment': {
            'intro': [
                '本章作业是设计题，不写 RTL。请独立完成系统设计并回答以下问题。',
            ],
            'questions': [
                {'q': '计算一个卷积层的 MAC 数：输入 28x28x8，3x3 卷积，输出 8 通道，stride=1，padding=1。写出公式和结果。',
                 'hint': '每个输出像素需要 3x3x8 次乘累加；输出大小仍为 28x28。'},
                {'q': '如果使用 8x8 脉动阵列，理想情况下上述卷积需要多少个周期？忽略权重加载和流水排空。',
                 'hint': '8x8 阵列每周期完成 64 个 MAC。'},
                {'q': '设计一张 MMIO 寄存器表：至少包含 CMD、STATUS、ADDR_SRC、ADDR_DST、LENGTH 五个寄存器，给出地址、方向、位宽和含义。',
                 'hint': '参考 0x7000 起始的地址段。'},
                {'q': '画出 NPU 系统数据流图，标注哪条路径是瓶颈，并说明为什么。',
                 'hint': '比较阵列算力与 SRAM/DMA 带宽。'},
                {'q': '为什么激活和权重要量化成 int8？如果量化后精度下降，应该先调什么？',
                 'hint': '考虑硬件面积、存储和 per-layer scale。'},
            ],
            'submission': [
                '设计文档（含系统框图）。',
                'MMIO 寄存器表。',
                'n2t_npu_top 端口草案（Verilog 注释形式即可）。',
                'Q1-Q5 的书面回答。',
            ],
            'rubric': [
                ('系统框图完整、数据流清晰', 25),
                ('MMIO 寄存器表完整且合理', 25),
                ('端口草案与现有整机风格一致', 15),
                ('MAC 数与周期估算正确', 20),
                ('瓶颈分析与量化论述', 15),
            ],
        },
    },
    {
        'num': 2,
        'title': '脉动阵列',
        'en_title': 'PE and Systolic Array',
        'project': {
            'background': [
                '上一章确定了 NPU 的系统架构。本章开始写真正的 RTL：先是单个乘累加单元 PE，再把它排列成 N x N 的 weight-stationary 脉动阵列。',
                '仓库里已经搭好作业框架：`solution/06/` 有完整答案，`assignment/06/` 有留空模板，`tb/06/` 有测试台。你的任务是补全模板并通过 `make sim-06`。',
            ],
            'objective': [
                '实现 `n2t_pe`：int8 x int8 + int32 累加的 MAC 单元。',
                '实现 `n2t_systolic_array`：参数化 N x N 脉动阵列，支持批量权重装载、斜输入和输出对齐。',
                '理解阵列语义：C[k][col] = sum_row A[row][k] * W[row][col]。',
            ],
            'deliverables': [
                '`assignment/06/PE.v`：完成后的 PE。',
                '`assignment/06/SystolicArray.v`：完成后的阵列。',
                '运行 `make sim-06` 得到全部 PASS。',
            ],
            'contract': [
                'PE：psum_out = psum_in + a_in * w，全部使用有符号运算。',
                '阵列：`w_data` 为 N*N*W_W 位，`a_data` 为 N*A_W 位，`psum_out` 为 N*P_W 位。',
                '时序：统一在 clk 下降沿提交，与仓库其他模块一致。',
                '测试：PE 6 项检查、SystolicArray 64 项检查全部通过。',
            ],
            'resources': [
                '`docs/npu.md`：数据布局、时序约定。',
                '`solution/06/PE.v` 与 `solution/06/SystolicArray.v`：参考实现。',
                '`tb/06/PE_tb.v` 与 `tb/06/SystolicArray_tb.v`：测试台。',
            ],
            'tips': [
                '先做 PE，用单独测试台验证乘法与累加，再做阵列。',
                '注意 Verilog 有符号：声明 `signed` 并用 32 位累加，防止截断。',
                '斜输入由阵列内部延迟实现；输出对齐消除列间偏移。',
                '调试时先用 4x4 参数跑通，再回到 8x8。',
            ],
        },
        'lecture': {
            'slides': [
                {'title': 'PE 与脉动阵列', 'bullets': [
                    '本章目标：实现 NPU 的计算核心。',
                    '内容：PE、weight-stationary 数据流、斜输入、输出对齐。',
                    '验收：make sim-06 全 PASS。',
                ]},
                {'title': '从乘累加开始', 'bullets': [
                    'MAC 是 CNN 的最小计算单元：acc += a * w。',
                    'int8 乘法 + int32 累加，精度与面积平衡。',
                    'PE 是 MAC 的硬件化：输入 a、权重 w、部分和 psum。',
                ]},
                {'title': 'PE 接口', 'bullets': [
                    'a_in / a_out：激活从左侧流入、向右流出。',
                    'psum_in / psum_out：部分和从上方流入、向下流出。',
                    'w_load / w_in：权重装载。',
                    '输出：psum_out = psum_in + a_in * w。',
                ]},
                {'title': '为什么叫脉动', 'bullets': [
                    '数据像心跳一样在 PE 之间逐拍流动。',
                    '每个 PE 只和邻居通信，没有全局广播。',
                    '寄存器流水让每个周期所有 PE 都在工作。',
                ]},
                {'title': 'Weight-Stationary 数据流', 'bullets': [
                    '权重先批量装载，之后停留在 PE 内。',
                    '激活逐拍流过阵列，部分和向下累加。',
                    '权重复用率 = 该权重被使用的次数。',
                    '卷积场景下权重复用率很高，适合这个方案。',
                ]},
                {'title': '斜输入', 'bullets': [
                    '阵列第 row 行的输入需要延迟 row 拍。',
                    '这样才能让所有行在同一拍处理同一个 k。',
                    '外部不需要打 skew：阵列内部自动对齐。',
                ]},
                {'title': '输出对齐', 'bullets': [
                    '列 j 的结果天然比列 j-1 晚一拍。',
                    '在底部对第 col 列额外延迟 N-1-col 拍。',
                    '最终所有列在同一拍输出，方便后续控制器取数。',
                ]},
                {'title': '时序示例', 'bullets': [
                    'w_load 高电平装载权重。',
                    '之后每拍送一个 a_data 向量。',
                    '最后一个输入送入后再等 N-1 拍，开始逐拍输出。',
                    '示例：N=8，送入 8 个向量，输出 8 个结果向量。',
                ]},
                {'title': '参数化设计', 'bullets': [
                    'N：阵列大小，8x8 起步，可扩展到 16x16。',
                    'A_W / W_W：激活和权重位宽，默认 8。',
                    'P_W：累加位宽，默认 32。',
                    '参数化让同一个 RTL 可以用于不同算力配置。',
                ]},
                {'title': '本章任务', 'bullets': [
                    '补全 PE：权重寄存器 + 有符号乘累加。',
                    '补全阵列：斜输入、PE 互联、输出对齐。',
                    '跑通 PE_tb 与 SystolicArray_tb。',
                ]},
                {'title': '常见错误', 'bullets': [
                    '忘记 signed，导致负数乘法错误。',
                    'w_data 位宽写成 N*W_W，应该是 N*N*W_W。',
                    '采样时机不对，把斜输出当成错误。',
                    '复位不完整，初值 x 传播到输出。',
                ]},
                {'title': '总结', 'bullets': [
                    'PE 是最小的 MAC 单元。',
                    '脉动阵列通过数据复用把 MAC 密度拉满。',
                    '斜输入 + 输出对齐是正确时序的关键。',
                    '下一章：给阵列加上 SRAM 和控制器，做真正的卷积。',
                ]},
            ],
        },
        'assignment': {
            'intro': [
                '本章作业分两部分：补全 RTL 并跑通测试；完成书面推导题。',
            ],
            'questions': [
                {'q': '手工模拟一个 3x3 脉动阵列计算 C = A^T * B（A、B 均为 3x3 int8），画出前 5 拍每个 PE 的输入与 psum。',
                 'hint': '用表格列出 cycle、row、a、psum。'},
                {'q': '推导 N x N 阵列完成一次 N x N 矩阵乘的总周期数（含装载、流水、输出对齐）。',
                 'hint': '装载 1 拍 + 输入 N 拍 + 排空 2N-2 拍。'},
                {'q': '为什么输出是斜的？输出对齐为什么不会改变计算结果？',
                 'hint': '比较列 j 与列 j-1 的 a 到达时间。'},
                {'q': '把 N 改成 4，测试台需要改哪些地方？运行结果是否与手算一致？',
                 'hint': '注意 w_data 位宽是 N*N*W_W。'},
                {'q': '证明 8x8、int8 输入的情况下，int32 累加不会溢出。',
                 'hint': '最大绝对值 127*127*8 = 129032，远小于 2^31。'},
            ],
            'submission': [
                '完成后的 PE.v 与 SystolicArray.v。',
                '`make sim-06` 的 PASS 输出。',
                'Q1-Q5 书面回答（含手工时序表）。',
            ],
            'rubric': [
                ('PE 实现正确', 20),
                ('SystolicArray 实现正确', 30),
                ('make sim-06 全部 PASS', 20),
                ('手工时序表正确', 15),
                ('书面推导完整', 15),
            ],
        },
    },
    {
        'num': 3,
        'title': 'GEMM 控制器与卷积数据通路',
        'en_title': 'GEMM Controller and Convolution Data Path',
        'project': {
            'background': [
                '脉动阵列只能做矩阵乘，还不能直接吃图片。本章在阵列外面加“神经系统”：SRAM、DMA/控制器、im2col 或 line buffer、ReLU、MaxPool 和全连接。',
                '阵列的输出格式是“一个空间位置的所有输出通道”，正好适合逐像素扫描的卷积控制器。',
            ],
            'objective': [
                '实现 `n2t_gemm_ctrl`（或 `n2t_conv_unit`）：把输入特征图切成矩阵乘喂给阵列。',
                '实现激活与池化单元：ReLU（量化版）与 MaxPool 2x2。',
                '实现全连接层：FC 直接复用阵列的矩阵乘能力。',
                '用 Python 生成的小规模 golden 数据完成 RTL 对比验证。',
            ],
            'deliverables': [
                '`assignment/07/` 下的控制器、激活/池化、全连接模块。',
                '对应的手工 testbench 与 golden 数据。',
                'Makefile 新增 `sim-07` 目标并全部 PASS。',
            ],
            'contract': [
                '卷积输出必须与 Python int8 参考实现逐元素一致。',
                '支持 stride=1/2、padding=0/1 的配置。',
                '数据通路与控制器分离：控制器产生地址和使能，数据通路只做运算。',
                '保持 negedge 时序约定。',
            ],
            'resources': [
                '`docs/npu.md` 的路线图。',
                '`solution/06/SystolicArray.v`：本章复用的计算核心。',
                'PyTorch / torchvision：用于生成 golden（本机已安装）。',
            ],
            'tips': [
                '先从 stride=1、padding=0 的 3x3 卷积开始，跑通后再加 padding。',
                '输入通道大于 8 时做通道 tiling：每次取 8 个通道送入阵列。',
                '用 FSM 控制状态：IDLE -> LOAD_W -> RUN -> DRAIN -> DONE。',
                'golden 先用 Python 整数运算生成，避免浮点误差干扰调试。',
            ],
        },
        'lecture': {
            'slides': [
                {'title': 'GEMM 控制器与卷积数据通路', 'bullets': [
                    '本章目标：让脉动阵列真正计算卷积。',
                    '内容：SRAM、控制器 FSM、im2col/line buffer、激活/池化/FC。',
                    '验收：小规模 golden 逐元素一致。',
                ]},
                {'title': '阵列输出的意义', 'bullets': [
                    'C[k][col] = sum_row A[row][k] * W[row][col]。',
                    '把 A 的行当作输入通道、列当作空间位置。',
                    'W 的行是输入通道、列是输出通道。',
                    '所以一拍算出一个像素的 N 个输出通道。',
                ]},
                {'title': 'SRAM 组织', 'bullets': [
                    '输入 SRAM：H x W x C_in，按通道-空间布局。',
                    '权重 SRAM：C_out x C_in x 3 x 3，按 im2col 后矩阵布局。',
                    '输出 SRAM：H x W x C_out。',
                    '规模估算：28x28x8 = 6272 字节，int8。',
                ]},
                {'title': '控制器 FSM', 'bullets': [
                    'IDLE：等待 CMD。',
                    'LOAD_W：从权重 SRAM 装载阵列。',
                    'RUN：逐像素产生 a_data 并收集 psum_out。',
                    'DRAIN：等待流水排空。',
                    'DONE：置位状态寄存器。',
                ]},
                {'title': 'im2col', 'bullets': [
                    '把 3x3 卷积窗口展开成行向量。',
                    '每个输出像素对应一个 K = C_in*3*3 维向量。',
                    '一行一行喂给阵列，等价于矩阵乘。',
                    '代价是数据重复，但硬件实现简单。',
                ]},
                {'title': 'Line Buffer', 'bullets': [
                    '逐行扫描图片时，只需要保留最近 3 行。',
                    'line buffer 可以避免整张图重复搬运。',
                    '适合流式卷积，减少 SRAM 带宽。',
                    '两种方案都可以，本章不强制。',
                ]},
                {'title': 'ReLU 与量化', 'bullets': [
                    'int32 累加结果需要反量化并重新量化到 int8。',
                    'ReLU 在量化域里就是 max(x, 0)。',
                    'LeakyReLU 需要查表或移位近似。',
                    '本章先用普通 ReLU。',
                ]},
                {'title': 'MaxPool', 'bullets': [
                    '2x2 窗口取最大值，stride=2 时宽高减半。',
                    '可以跟在卷积输出后做流式处理。',
                    '实现简单：比较器 + 计数器。',
                    'Pooling 不做乘法，不占用阵列。',
                ]},
                {'title': '全连接 = GEMM', 'bullets': [
                    'FC 层就是矩阵乘：输入向量 x 权重矩阵。',
                    '复用同一个控制器，只是没有滑动窗口。',
                    'MNIST 小模型最后的 784->64->10 都是 FC。',
                    '阵列位宽不足时按 8 通道 tiling。',
                ]},
                {'title': 'Golden 验证', 'bullets': [
                    '用 Python 写 int8 参考实现。',
                    '每层输出导出为 hex 文件。',
                    'RTL testbench 逐层比对。',
                    '先单层验证，再做层间串联。',
                ]},
                {'title': '本章任务', 'bullets': [
                    '实现卷积控制器与数据通路。',
                    '实现 ReLU 与 MaxPool。',
                    '实现 FC 层。',
                    '与 Python golden 逐元素一致。',
                ]},
                {'title': '总结', 'bullets': [
                    '控制器决定“什么时候把什么数据送到阵列”。',
                    'im2col 与 line buffer 是两种空间换带宽的方案。',
                    '激活/池化跟在累加之后，仍是数据流的一部分。',
                    '下一章解决“权重从哪来”：模型训练与量化导出。',
                ]},
            ],
        },
        'assignment': {
            'intro': [
                '本章作业包含控制器设计、RTL 实现与 golden 对比。',
            ],
            'questions': [
                {'q': '画出卷积控制器的 FSM，标注每个状态做什么、什么时候跳转。',
                 'hint': '至少包含 IDLE/LOAD_W/RUN/DRAIN/DONE。'},
                {'q': '输入 28x28x8、3x3 卷积、输出 8 通道，im2col 后矩阵的维度是多少？每个矩阵元素来自哪里？',
                 'hint': 'K = 8*3*3 = 72，输出像素数 = 28*28。'},
                {'q': '计算 28x28x8 输入 SRAM 和输出 SRAM 的最小容量（int8，含 padding 考虑）。',
                 'hint': '28x28x8 = 6272 字节；padding 后边界像素需要额外存储。'},
                {'q': '解释 line buffer 如何降低带宽：与 im2col 相比各有什么优缺点？',
                 'hint': '重复读取次数 vs 硬件复杂度。'},
                {'q': '设计 golden 生成策略：如何保证 Python 参考实现与 RTL 数值一致？',
                 'hint': '用整数运算、避免浮点；逐层导出。'},
            ],
            'submission': [
                '控制器、激活/池化、FC 的 RTL 源码。',
                'golden 数据与 testbench。',
                '`make sim-07` 的 PASS 输出。',
                'Q1-Q5 书面回答。',
            ],
            'rubric': [
                ('FSM 设计正确', 20),
                ('卷积与 golden 一致', 30),
                ('ReLU/MaxPool 正确', 15),
                ('FC 复用阵列正确', 15),
                ('书面推导与带宽分析', 20),
            ],
        },
    },
    {
        'num': 4,
        'title': '模型训练与量化导出',
        'en_title': 'Model Training, Quantization and Export',
        'project': {
            'background': [
                '硬件已经具备计算卷积和全连接的能力，但还没有权重。本章用 PyTorch 训练一个很小的 MNIST 分类模型，做后训练量化，并把权重和 golden 输出导出成 RTL 能加载的格式。',
                '这是“软件定义硬件数据”的环节：模型结构、每层 scale、导出布局都会直接影响 RTL 控制器。',
            ],
            'objective': [
                '训练一个 tiny CNN（约 1-5 万参数），MNIST 准确率不低于 95%。',
                '实现 int8 后训练量化：权重、激活都映射到 [-128, 127]。',
                '编写 `tools/npu_mnist.py`，导出 weights.hex、image.hex、golden.hex、scales.json。',
                '用 Python int8 参考模拟器验证导出的权重和 golden。',
            ],
            'deliverables': [
                '`tools/npu_mnist.py`：训练、量化、导出一体脚本。',
                '`npu_data/`：权重、图片、golden、scale 文件。',
                '量化精度报告：float 模型 vs int8 模拟的准确率对比。',
            ],
            'contract': [
                '导出格式必须与 Ch3 定义的 SRAM 布局一致（行主序、int8 补码）。',
                '同一份权重在 Python int8 模拟与 RTL 中必须得到相同结果。',
                '脚本可重复：固定随机种子，`python3 tools/npu_mnist.py --all` 一键完成。',
            ],
            'resources': [
                '本机已安装 PyTorch 2.13 与 torchvision 0.28。',
                '`docs/npu.md` 中的模型结构建议。',
                'Ch3 的 golden 格式约定。',
            ],
            'tips': [
                '先训练一个浮点小模型，再量化；不要一开始就追求大模型。',
                '量化最简单的方式：per-tensor min/max -> scale = range/255。',
                '把 BN 折叠进卷积权重，减少 RTL 工作量。',
                'golden 用整数运算生成：round 规则必须与 RTL 一致（四舍五入）。',
            ],
        },
        'lecture': {
            'slides': [
                {'title': '模型训练与量化导出', 'bullets': [
                    '本章目标：给 NPU 提供权重和验证数据。',
                    '内容：tiny CNN、MNIST、后训练量化、导出格式。',
                    '产出：npu_mnist.py + npu_data/ 目录。',
                ]},
                {'title': '为什么先做分类', 'bullets': [
                    '分类模型只有 conv + pool + FC。',
                    '没有 YOLO 的检测头、NMS、多尺度。',
                    'MNIST 小、训练快、验证直观。',
                    '跑通后可以替换成更大的数据集/模型。',
                ]},
                {'title': '模型结构', 'bullets': [
                    'Conv(1->8, 3x3) + ReLU + MaxPool -> 14x14x8。',
                    'Conv(8->16, 3x3) + ReLU + MaxPool -> 7x7x16。',
                    'Flatten(784) -> FC(64) -> ReLU -> FC(10)。',
                    '参数约 5 万，int8 权重约 50KB。',
                ]},
                {'title': '训练要点', 'bullets': [
                    '固定随机种子，保证可复现。',
                    'MNIST 归一化到 [0,1] 或 [-1,1]。',
                    'Adam + 少量 epoch 即可收敛。',
                    '目标：float 准确率 > 97%，int8 后 > 95%。',
                ]},
                {'title': '为什么要量化', 'bullets': [
                    '硬件乘法器是 int8 x int8。',
                    'float32 权重会占 4 倍存储。',
                    'int8 推理是嵌入式 NPU 的事实标准。',
                    '量化误差可以通过 scale 逐层校正。',
                ]},
                {'title': '后训练量化', 'bullets': [
                    '用校准集统计每层激活的 min/max。',
                    'scale = (max - min) / 255，zero_point 可省略（对称量化）。',
                    'q = round(clamp(x / scale, -128, 127))。',
                    '累加结果反量化：out_fp = out_int * scale_act * scale_w。',
                ]},
                {'title': 'BN 折叠', 'bullets': [
                    'BatchNorm 在推理时可以并入前一层卷积。',
                    'w_fold = w * gamma / sqrt(var + eps)。',
                    'b_fold = (b - mean) * gamma / sqrt(var + eps) + beta。',
                    '这样 RTL 不需要单独实现 BN。',
                ]},
                {'title': '导出格式', 'bullets': [
                    'weights.hex：逐层权重，行主序，每行一个 int8 补码十六进制。',
                    'image.hex：一张测试图片。',
                    'golden.hex：每层 int8 输出（或最终 logits）。',
                    'scales.json：每层 scale / zero_point / 布局信息。',
                ]},
                {'title': 'Python int8 模拟器', 'bullets': [
                    '用 PyTorch 张量实现量化 forward。',
                    '每层输出量化回 int8，与 RTL 行为一致。',
                    '这就是 RTL testbench 的 golden。',
                    '先把 Python 模拟器调对，再碰硬件。',
                ]},
                {'title': '常见坑', 'bullets': [
                    'round 规则不一致（Python 银行家舍入 vs 四舍五入）。',
                    'scale 用 float 计算但导出时精度丢失。',
                    'ReLU 之后负半轴被截断，min 不能直接用负值。',
                    '权重/激活布局与 RTL 地址映射不一致。',
                ]},
                {'title': '本章任务', 'bullets': [
                    '训练 tiny CNN 并量化。',
                    '实现导出脚本与 Python int8 模拟器。',
                    '生成 npu_data/ 全部文件。',
                    '提交量化精度报告。',
                ]},
                {'title': '总结', 'bullets': [
                    '模型结构要和硬件能力对齐：小、int8、无复杂算子。',
                    '量化不是精度损失的结束，而是工程取舍的开始。',
                    '导出格式就是硬件和软件之间的接口。',
                    '下一章：把 NPU 挂回 Hack Computer，跑端到端推理。',
                ]},
            ],
        },
        'assignment': {
            'intro': [
                '本章作业以脚本和报告为主，最终要有一份“float vs int8”的精度对比。',
            ],
            'questions': [
                {'q': '给出你的 tiny CNN 结构，说明为什么选择这些通道数和层数。',
                 'hint': '考虑 8x8 阵列的 tiling 和 MNIST 输入大小。'},
                {'q': '取一个卷积层的权重张量，手工计算 per-tensor scale，并量化 5 个示例值。',
                 'hint': 'scale = max(abs(w)) / 127（对称量化）。'},
                {'q': '解释为什么推理时可以把 BN 折叠进卷积，并写出折叠公式。',
                 'hint': '推理时 mean/var 是常量。'},
                {'q': 'Python int8 模拟的准确率比 float 低多少？如果低于 95%，你会怎么调整？',
                 'hint': '调 scale、校准集、模型容量。'},
                {'q': '设计一个端到端检查：如何证明 RTL 的最终 logits 与 Python golden 一致？',
                 'hint': 'argmax 一致 + 数值误差上界。'},
            ],
            'submission': [
                'tools/npu_mnist.py 源码。',
                'npu_data/ 生成文件。',
                '量化精度报告（float vs int8）。',
                'Q1-Q5 书面回答。',
            ],
            'rubric': [
                ('训练脚本可复现', 20),
                ('量化实现正确', 25),
                ('导出格式与 RTL 布局一致', 25),
                ('精度报告完整', 15),
                ('书面推导正确', 15),
            ],
        },
    },
    {
        'num': 5,
        'title': '整机集成与端到端推理',
        'en_title': 'SoC Integration and End-to-End Inference',
        'project': {
            'background': [
                '现在 NPU 有算力、有控制器、有权重。最后一步是把 NPU 作为外设挂进现有 Hack Computer，用 Hack 机器码发起一次 MNIST 推理，并把结果写回内存。',
                '这一章把 nand2tetris 的整机（Project 5）和前面的 NPU 工程串成一条完整链路：CPU 调度 -> NPU 计算 -> 结果回读。',
            ],
            'objective': [
                '扩展 `n2t_memory` / `n2t_computer`：在 0x7000-0x7FFF 增加 NPU MMIO。',
                '编写一条 Hack 汇编驱动：写命令、轮询状态、读取结果。',
                '集成测试：加载一张 MNIST 图片，端到端输出正确类别。',
                '保持原有 `make test`（Project 1/2/3/5/6）全部通过。',
            ],
            'deliverables': [
                '改造后的 Memory.v / Computer.v（向后兼容）。',
                'Hack 驱动 `npu_driver.asm` + 编译后的 `npu_driver.hack`。',
                '端到端集成 testbench 与 PASS 输出。',
            ],
            'contract': [
                '原有官方测试必须继续全绿（不破坏 nand2tetris 语义）。',
                'MMIO 地址不与 RAM/Screen/Keyboard 冲突。',
                '驱动必须通过轮询 STATUS 等待 NPU 完成，不允许 busy-wait 死循环失控。',
                '最终结果写入约定内存地址，测试台能够读到并断言正确类别。',
            ],
            'resources': [
                '`solution/05/Computer.v`、`solution/05/Memory.v`、`solution/05/ROM32K.v`。',
                '`programs/*.hack`：现有 Hack 程序示例。',
                'Ch4 导出的 image.hex / weights.hex / scales.json。',
            ],
            'tips': [
                '先在 Memory 里加一个简单的 MMIO 译码，再接 NPU；不要一步到位。',
                'Hack 没有乘法，驱动里只做地址计算和轮询，计算全部交给 NPU。',
                '用 waveform 观察 CMD 与 STATUS 的时序，确认没有握手竞争。',
                '端到端先跑 1 张图，验证 argmax 后再考虑批量。',
            ],
        },
        'lecture': {
            'slides': [
                {'title': '整机集成与端到端推理', 'bullets': [
                    '本章目标：Hack CPU + NPU 组成完整系统。',
                    '内容：MMIO 扩展、Hack 驱动、集成测试。',
                    '最终成果：一条命令完成 MNIST 分类。',
                ]},
                {'title': 'Hack + NPU 系统', 'bullets': [
                    'CPU：运行 Hack 机器码，负责调度。',
                    'Memory：RAM/Screen/Keyboard + NPU MMIO。',
                    'NPU：独立时钟域或同源时钟，完成计算。',
                    '数据流：ROM 程序 -> CPU -> MMIO -> NPU -> RAM。',
                ]},
                {'title': 'MMIO 地址分配', 'bullets': [
                    '0x0000-0x3FFF：RAM16K。',
                    '0x4000-0x5FFF：Screen。',
                    '0x6000：Keyboard。',
                    '0x7000-0x7FFF：NPU 寄存器与缓冲区（新增）。',
                ]},
                {'title': '命令协议', 'bullets': [
                    'CPU 把图片地址、权重地址、层数写入寄存器。',
                    'CPU 写 CMD=START，NPU 开始执行。',
                    'NPU 执行时置 BUSY=1。',
                    '完成后 BUSY=0、DONE=1，结果写入约定地址。',
                ]},
                {'title': 'Hack 驱动', 'bullets': [
                    '汇编伪代码：写 ADDR_SRC、写 ADDR_DST、写 CMD、轮询 STATUS。',
                    'Hack 没有函数调用栈，用小标签和跳转即可。',
                    '驱动只做 I/O 和地址计算，不做矩阵运算。',
                    '完成后读取结果 RAM，比较 argmax。',
                ]},
                {'title': '轮询 vs 中断', 'bullets': [
                    '轮询：CPU 循环读 STATUS，简单可靠。',
                    '中断：需要扩展 Hack 指令集或外设引脚，复杂。',
                    '本章用轮询，符合 nand2tetris 的极简风格。',
                    '真实 SoC 中轮询对小任务完全够用。',
                ]},
                {'title': '集成测试', 'bullets': [
                    '用 Ch4 的一张测试图片作为输入。',
                    'NPU 权重在仿真启动时从文件加载。',
                    'CPU 跑驱动，NPU 跑推理。',
                    'testbench 检查最终类别并打印 PASS。',
                ]},
                {'title': '调试方法', 'bullets': [
                    '先单独测 MMIO 读写，再测 NPU 状态机。',
                    '用 VCD 波形检查 CMD/STATUS 握手。',
                    '逐层比对 NPU 输出与 golden。',
                    '不一致时从最后一层往前定位。',
                ]},
                {'title': '性能度量', 'bullets': [
                    '统计从 START 到 DONE 的周期数。',
                    '对比理论 MAC 周期数，算出阵列利用率。',
                    '瓶颈通常在 DMA/权重加载，而不是阵列。',
                    '利用率报告是本章加分项。',
                ]},
                {'title': '扩展方向', 'bullets': [
                    '把 MNIST 换成 CIFAR-10 或自定义数据集。',
                    '增加批量推理与流水。',
                    '评估 tiny YOLO 的 conv 部分。',
                    'NMS 等后处理可以继续留在 CPU/Python。',
                ]},
                {'title': '本章任务', 'bullets': [
                    '扩展 Memory/Computer 的 MMIO。',
                    '写 Hack 驱动并编译。',
                    '跑通端到端 MNIST 推理。',
                    '保持全部历史测试通过。',
                ]},
                {'title': '总结', 'bullets': [
                    '从 Nand 到 Hack，再到 NPU：一条完整的现代计算机链路。',
                    'MMIO 是 CPU 与外设之间的桥梁。',
                    '小分类模型是端到端验证的完美载体。',
                    '后续可以按同样框架挑战 tiny YOLO。',
                ]},
            ],
        },
        'assignment': {
            'intro': [
                '本章是收官作业：系统集成 + 驱动 + 端到端验证。',
            ],
            'questions': [
                {'q': '写出 Hack 驱动的伪代码：加载地址、启动 NPU、轮询完成、读取结果。',
                 'hint': '用伪代码或 Hack 汇编均可。'},
                {'q': '设计命令描述符：如果一次推理包含多层，CPU 如何把“每层的地址和参数”告诉 NPU？',
                 'hint': '可以定义内存中的描述符表，CPU 只写表头地址。'},
                {'q': '从 START 到 DONE 统计实际周期，并与 Ch2/Ch3 的理论周期对比，分析差距来源。',
                 'hint': '权重加载、tiling、流水排空、轮询开销都算。'},
                {'q': '如果端到端结果与 golden 不一致，给出你的排查顺序。',
                 'hint': 'MMIO -> 状态机 -> 单层输出 -> 量化参数。'},
                {'q': '评估把本章系统扩展到 tiny YOLO 需要改哪些部分，哪些可以复用。',
                 'hint': 'conv/FC 复用；需要 upsample、concat、检测头、NMS。'},
            ],
            'submission': [
                '改造后的 Memory.v / Computer.v。',
                'npu_driver.asm 与 .hack。',
                '集成 testbench 的 PASS 输出。',
                '性能与利用率报告。',
                'Q1-Q5 书面回答。',
            ],
            'rubric': [
                ('MMIO 集成正确且向后兼容', 25),
                ('Hack 驱动正确', 20),
                ('端到端推理 PASS', 30),
                ('性能报告', 10),
                ('书面回答', 15),
            ],
        },
    },
]


def main():
    register_font()
    st = build_styles()
    wanted = set(sys.argv[1:]) or {str(c['num']) for c in CHAPTERS}
    for ch in CHAPTERS:
        if str(ch['num']) not in wanted:
            continue
        render_project(ch['num'], ch, st)
        render_lecture(ch['num'], ch, st)
        render_assignment(ch['num'], ch, st)
    print('done: %d chapter(s), 3 PDFs each' % len(wanted))


if __name__ == '__main__':
    main()
