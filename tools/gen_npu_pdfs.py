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
import math
import sys

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.lib.utils import simpleSplit
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.cidfonts import UnicodeCIDFont
from reportlab.graphics.shapes import Drawing, Rect, String, Line, Polygon
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
                                      fontName=FONT, fontSize=13, leading=20,
                                      textColor=DARK, spaceAfter=8)
    st['slide_bullet'] = ParagraphStyle('slide_bullet', parent=s['Normal'],
                                        fontName=FONT, fontSize=13,
                                        leading=20, textColor=DARK,
                                        leftIndent=18, bulletIndent=4,
                                        spaceAfter=6)
    return st


# ---------------------------------------------------------------------------
# 配图绘制工具（reportlab 矢量图，全部可缩放、无需外部图片）
# ---------------------------------------------------------------------------

def _diagram(w, h):
    return Drawing(w, h)


def _box(d, x, y, w, h, label='', fs=9, fill=colors.white,
         stroke=colors.black, tc=DARK, lw=1):
    d.add(Rect(x, y, w, h, fillColor=fill, strokeColor=stroke,
               strokeWidth=lw))
    if label:
        d.add(String(x + w / 2.0, y + h / 2.0 - fs * 0.35, label,
                     fontName=FONT, fontSize=fs, fillColor=tc,
                     textAnchor='middle'))


def _dtext(d, x, y, text, fs=9, anchor='middle', color=DARK):
    d.add(String(x, y, text, fontName=FONT, fontSize=fs,
                 fillColor=color, textAnchor=anchor))


def _arrow(d, x1, y1, x2, y2, label='', color=ORANGE, lw=1.4, fs=8):
    d.add(Line(x1, y1, x2, y2, strokeColor=color, strokeWidth=lw))
    ang = math.atan2(y2 - y1, x2 - x1)
    L = 7
    p1 = (x2 - L * math.cos(ang - 0.42), y2 - L * math.sin(ang - 0.42))
    p2 = (x2 - L * math.cos(ang + 0.42), y2 - L * math.sin(ang + 0.42))
    d.add(Polygon([x2, y2, p1[0], p1[1], p2[0], p2[1]],
                  fillColor=color, strokeColor=color))
    if label:
        _dtext(d, (x1 + x2) / 2.0, (y1 + y2) / 2.0 + 3, label, fs=fs)


def diag_system():
    """Ch1：CPU / Memory / NPU 系统框图。"""
    d = _diagram(560, 250)
    _box(d, 20, 150, 120, 70, 'Hack CPU\n(调度器)', fs=10,
         fill=LIGHT, stroke=ORANGE)
    _box(d, 220, 150, 120, 70, 'Memory\n(含 MMIO)', fs=10,
         fill=LIGHT, stroke=ORANGE)
    _box(d, 420, 150, 120, 70, 'NPU\n(加速器)', fs=10,
         fill=LIGHT, stroke=ORANGE)
    _arrow(d, 140, 185, 220, 185, '读写')
    _arrow(d, 340, 185, 420, 185, 'MMIO')
    _box(d, 60, 30, 130, 60, '命令/状态\n寄存器', fs=9)
    _box(d, 215, 30, 130, 60, '权重/输入\nSRAM', fs=9)
    _box(d, 370, 30, 130, 60, '脉动阵列\n8x8', fs=9)
    _arrow(d, 125, 90, 125, 150, 'CPU 控制')
    _arrow(d, 280, 90, 280, 150, '数据搬运')
    _arrow(d, 435, 90, 435, 150, '计算')
    _dtext(d, 280, 10, '图 1：Hack CPU 只做调度，重计算全部下沉到 NPU',
           fs=8, color=GRAY)
    return d


def diag_addr_map():
    """Ch1：Hack 地址空间与 NPU MMIO 段。"""
    d = _diagram(420, 380)
    rows = [
        ('0x7000 - 0x7FFF', 'NPU 寄存器 / 数据缓冲（新增）', ORANGE, 110),
        ('0x6000', 'Keyboard（只读）', colors.white, 40),
        ('0x4000 - 0x5FFF', 'Screen（8K 字）', LIGHT, 70),
        ('0x0000 - 0x3FFF', 'RAM16K（64KB）', LIGHT, 90),
    ]
    y = 20
    for label, desc, fill, h in rows:
        _box(d, 30, y, 150, h, label, fs=9, fill=fill, stroke=ORANGE)
        _dtext(d, 280, y + h / 2 - 4, desc, fs=9)
        y += h + 6
    _dtext(d, 210, 365, '图 2：Hack 地址空间。0x7000 以上原本未使用，',
           fs=8, color=GRAY)
    _dtext(d, 210, 352, '正好预留给 NPU。', fs=8, color=GRAY)
    return d


def diag_mmio_flow():
    """Ch1：MMIO 写命令 / 轮询状态 的握手。"""
    d = _diagram(560, 210)
    _box(d, 20, 90, 130, 60, 'CPU\n写 CMD=START', fs=9, fill=LIGHT)
    _box(d, 215, 90, 130, 60, 'NPU\n执行推理', fs=9, fill=LIGHT)
    _box(d, 410, 90, 130, 60, 'CPU\n读 STATUS', fs=9, fill=LIGHT)
    _arrow(d, 150, 120, 215, 120, '1')
    _arrow(d, 345, 120, 410, 120, '2: DONE=1')
    _box(d, 20, 10, 520, 45,
         'CPU 视角：写命令 -> 忙等（轮询） -> 读到完成位 -> 读结果',
         fs=9, fill=LIGHT)
    _dtext(d, 280, 185, '图 3：MMIO 的本质就是“把外设寄存器当成内存地址来读写”。',
           fs=8, color=GRAY)
    return d


def diag_int8():
    """Ch1：float -> int8 量化映射。"""
    d = _diagram(560, 170)
    _dtext(d, 50, 120, '浮点范围 [-1.0, 1.0]', fs=9, anchor='start')
    _arrow(d, 50, 110, 510, 110)
    _dtext(d, 50, 96, '-1.0', fs=8)
    _dtext(d, 280, 96, '0.0', fs=8)
    _dtext(d, 510, 96, '1.0', fs=8)
    _dtext(d, 50, 50, 'int8 范围 [-128, 127]', fs=9, anchor='start')
    _arrow(d, 50, 40, 510, 40)
    _dtext(d, 50, 26, '-128', fs=8)
    _dtext(d, 280, 26, '0', fs=8)
    _dtext(d, 510, 26, '127', fs=8)
    _dtext(d, 280, 145, '图 4：q = round(clamp(x / scale))，scale = 1/127。',
           fs=8, color=GRAY)
    return d


def diag_pe():
    """Ch2：PE 数据流。"""
    d = _diagram(420, 260)
    _box(d, 140, 90, 140, 80, 'PE\npsum += a * w', fs=10,
         fill=LIGHT, stroke=ORANGE)
    _arrow(d, 30, 130, 140, 130, 'a_in')
    _arrow(d, 280, 130, 390, 130, 'a_out')
    _arrow(d, 210, 210, 210, 170, 'psum_in')
    _arrow(d, 210, 90, 210, 50, 'psum_out')
    _arrow(d, 330, 210, 330, 170, 'w_load')
    _dtext(d, 210, 20, '图 5：激活向右流，部分和向下流，权重装载后驻留。',
           fs=8, color=GRAY)
    return d


def diag_array():
    """Ch2：4x4 脉动阵列。"""
    d = _diagram(520, 320)
    n = 4
    cw, ch, gap = 50, 38, 14
    x0, y0 = 80, 70
    for i in range(n):
        for j in range(n):
            _box(d, x0 + j * (cw + gap), y0 + (n - 1 - i) * (ch + gap),
                 cw, ch, 'PE', fs=8, fill=LIGHT, stroke=ORANGE)
    for i in range(n):
        y = y0 + (n - 1 - i) * (ch + gap) + ch / 2
        _arrow(d, 30, y, x0, y)
    for j in range(n):
        x = x0 + j * (cw + gap) + cw / 2
        _arrow(d, x, y0 + n * (ch + gap) + 5, x, y0 + n * (ch + gap) + 25,
               'psum 0')
    _dtext(d, 260, 300, '图 6：N x N PE 阵列。激活从左侧流入，',
           fs=8, color=GRAY)
    _dtext(d, 260, 288, '部分和从顶部流入、逐行累加。', fs=8, color=GRAY)
    return d


def diag_skew():
    """Ch2：斜输入示意。"""
    d = _diagram(520, 200)
    rows = [('row0', 40), ('row1', 90), ('row2', 140)]
    for label, y in rows:
        _dtext(d, 30, y + 10, label, fs=9, anchor='start')
    colors3 = [ORANGE, LIGHT, colors.HexColor('#DDDDDD')]
    for r, (label, y) in enumerate(rows):
        for k in range(6):
            _box(d, 80 + k * 45, y, 38, 22, 'k%d' % k, fs=7,
                 fill=colors3[(r + k) % 3], stroke=ORANGE)
    _dtext(d, 260, 175,
           '图 7：row i 的输入序列整体延迟 i 拍（斜输入），'
           '保证同一列在同一拍处理同一个 k。', fs=8, color=GRAY)
    return d


def diag_align():
    """Ch2：输出对齐。"""
    d = _diagram(540, 210)
    _dtext(d, 130, 180, '对齐前（各列差一拍）', fs=9)
    cols = [
        (90, 'col0'), (140, 'col1'), (190, 'col2'),
    ]
    for x, lab in cols:
        _dtext(d, x, 160, lab, fs=8)
        _box(d, x, 130, 30, 15, '', fill=ORANGE)
    _dtext(d, 300, 180, '延迟 N-1-col 拍后', fs=9)
    _dtext(d, 350, 160, 'col0  col1  col2', fs=8)
    for i in range(3):
        _box(d, 320 + i * 55, 130, 30, 15, '', fill=LIGHT,
             stroke=ORANGE)
    _arrow(d, 250, 137, 310, 137, '对齐')
    _dtext(d, 270, 90, '图 8：底部加移位寄存器，把不同列的斜输出拉齐到同一拍。',
           fs=8, color=GRAY)
    return d


def diag_timing():
    """Ch2：脉动阵列时序。"""
    d = _diagram(540, 200)
    y0 = 40
    labels = ['clk', 'w_load', 'a_data', 'psum_out']
    for i, lab in enumerate(labels):
        y = y0 + i * 40
        _dtext(d, 40, y + 8, lab, fs=9, anchor='start')
        _arrow(d, 90, y, 500, y, color=GRAY, lw=1)
        if lab == 'clk':
            for t in range(0, 8, 2):
                _box(d, 90 + t * 25, y, 25, 12, '', fill=ORANGE)
        elif lab == 'w_load':
            _box(d, 90, y, 25, 12, '', fill=ORANGE)
        elif lab == 'a_data':
            for t in range(8):
                _box(d, 90 + t * 25, y, 25, 12, 'k%d' % t, fs=6,
                     fill=LIGHT)
        elif lab == 'psum_out':
            for t in range(8):
                _box(d, 90 + (t + 7) * 25, y, 25, 12, 'C%d' % t, fs=6,
                     fill=ORANGE)
    _dtext(d, 270, 12, '图 9：送 8 个 a_data 后，输出从第 7 拍起逐拍出现。',
           fs=8, color=GRAY)
    return d


def diag_sram():
    """Ch3：SRAM 布局。"""
    d = _diagram(540, 200)
    _box(d, 30, 70, 120, 60, '输入 SRAM\nHxWxC', fs=9, fill=LIGHT)
    _box(d, 190, 70, 120, 60, '权重 SRAM\nCout x K', fs=9, fill=LIGHT)
    _box(d, 350, 70, 160, 60, '脉动阵列\n8x8', fs=10, fill=ORANGE,
         stroke=ORANGE, tc=colors.white)
    _box(d, 30, 10, 120, 40, '输出 SRAM\nHxWxCout', fs=9, fill=LIGHT)
    _arrow(d, 150, 100, 190, 100, '数据')
    _arrow(d, 310, 100, 350, 100, '权重')
    _arrow(d, 350, 70, 350, 50, '结果', color=GRAY)
    _arrow(d, 350, 50, 150, 30, '', color=GRAY)
    _dtext(d, 270, 175, '图 11：SRAM 负责把数据喂给阵列，并接住结果。',
           fs=8, color=GRAY)
    return d


def diag_linebuffer():
    """Ch3：Line Buffer 滑动窗口。"""
    d = _diagram(520, 210)
    rows = 3
    cols = 6
    for i in range(rows):
        for j in range(cols):
            _box(d, 60 + j * 40, 100 - i * 45, 36, 36, '', fs=6,
                 fill=colors.white, stroke=ORANGE)
    for i in range(rows):
        for j in range(3):
            _box(d, 100 + j * 40, 100 - i * 45, 36, 36, '', fs=6,
                 fill=LIGHT, stroke=ORANGE, lw=2)
    _arrow(d, 320, 120, 380, 120, '向右滑')
    _dtext(d, 260, 185, '图 12：只保留最近 3 行，窗口逐列滑动，'
                        '避免整图重复搬运。', fs=8, color=GRAY)
    return d


def diag_fsm():
    """Ch3：卷积控制器状态机。"""
    d = _diagram(580, 220)
    states = [
        (30, 'IDLE', LIGHT), (150, 'LOAD_W', LIGHT),
        (270, 'RUN', LIGHT), (390, 'DRAIN', LIGHT), (500, 'DONE', ORANGE),
    ]
    for x, name, fill in states:
        _box(d, x, 80, 60, 45, name, fs=9, fill=fill, stroke=ORANGE)
        if x < 500:
            _arrow(d, x + 60, 102, x + 90, 102)
    _dtext(d, 60, 50, '收到 CMD', fs=7)
    _dtext(d, 180, 50, '权重装载完', fs=7)
    _dtext(d, 300, 50, '像素送完', fs=7)
    _dtext(d, 420, 50, '流水排空', fs=7)
    _arrow(d, 530, 80, 530, 40, '', color=GRAY)
    _arrow(d, 60, 40, 60, 80, '', color=GRAY)
    _dtext(d, 280, 20, '图 9：控制器就是一个小型状态机。', fs=8, color=GRAY)
    return d


def diag_export():
    """Ch4：导出流水线。"""
    d = _diagram(560, 200)
    steps = [
        (20, 'PyTorch\n训练', LIGHT),
        (120, '后训练\n量化', LIGHT),
        (220, '导出\nhex/json', LIGHT),
        (320, 'Python int8\n模拟', LIGHT),
        (420, 'golden\n文件', ORANGE),
    ]
    for x, name, fill in steps:
        _box(d, x, 80, 90, 60, name, fs=8, fill=fill, stroke=ORANGE)
        if x < 420:
            _arrow(d, x + 90, 110, x + 120, 110)
    _dtext(d, 280, 25, '图 14：软件端先生成 golden，RTL 再逐层对齐。',
           fs=8, color=GRAY)
    return d


def diag_driver():
    """Ch5：Hack 驱动流程图。"""
    d = _diagram(420, 240)
    boxes = [
        (130, 180, '写输入/权重地址'),
        (130, 120, '写 CMD=START'),
        (130, 60, '轮询 STATUS'),
    ]
    for x, y, name in boxes:
        _box(d, x, y, 160, 45, name, fs=9, fill=LIGHT, stroke=ORANGE)
    _arrow(d, 210, 180, 210, 165)
    _arrow(d, 210, 120, 210, 105)
    _box(d, 330, 60, 70, 45, 'DONE?', fs=8)
    _arrow(d, 290, 82, 330, 82)
    _arrow(d, 365, 60, 365, 20, '否', color=GRAY)
    _arrow(d, 365, 20, 210, 20, '', color=GRAY)
    _arrow(d, 210, 20, 210, 60, '', color=GRAY)
    _box(d, 130, 10, 160, 40, '读结果/argmax', fs=9, fill=ORANGE,
         stroke=ORANGE, tc=colors.white)
    _arrow(d, 365, 105, 365, 90, '是')
    _arrow(d, 365, 90, 290, 30)
    _dtext(d, 210, 225, '图 16：驱动只做 I/O 和轮询，不做计算。',
           fs=8, color=GRAY)
    return d


def diag_im2col():
    """Ch3：im2col 示意。"""
    d = _diagram(560, 220)
    _dtext(d, 120, 190, '输入特征图 4x4', fs=9)
    for i in range(4):
        for j in range(4):
            _box(d, 60 + j * 30, 60 + i * 30, 28, 28, '', fs=6,
                 fill=colors.white, stroke=ORANGE)
    for i in range(3):
        for j in range(3):
            _box(d, 90 + j * 30, 60 + i * 30, 28, 28, '', fs=6,
                 fill=LIGHT, stroke=ORANGE, lw=2)
    _arrow(d, 220, 120, 280, 120, '展平')
    _dtext(d, 380, 190, 'im2col 矩阵的一行', fs=9)
    for k in range(9):
        _box(d, 280 + k * 30, 110, 28, 28, 'x%d' % k, fs=7,
             fill=LIGHT, stroke=ORANGE)
    _dtext(d, 280, 30, '图 10：每个输出像素的 3x3x通道 窗口展开成一行，',
           fs=8, color=GRAY)
    _dtext(d, 280, 17, '整个卷积就变成矩阵乘。', fs=8, color=GRAY)
    return d


def diag_pool():
    """Ch3：MaxPool 2x2。"""
    d = _diagram(420, 220)
    _dtext(d, 110, 190, '输入 4x4', fs=9)
    vals = [['1', '3', '2', '4'],
            ['5', '6', '8', '7'],
            ['2', '0', '3', '1'],
            ['9', '4', '2', '5']]
    for i in range(4):
        for j in range(4):
            _box(d, 40 + j * 36, 50 + i * 36, 34, 34, vals[i][j], fs=8,
                 fill=LIGHT, stroke=ORANGE)
    _arrow(d, 220, 120, 270, 120, 'max')
    _dtext(d, 340, 190, '输出 2x2', fs=9)
    out = [['6', '8'], ['9', '5']]
    for i in range(2):
        for j in range(2):
            _box(d, 300 + j * 50, 90 + i * 50, 48, 48, out[i][j], fs=10,
                 fill=ORANGE, stroke=ORANGE, tc=colors.white)
    _dtext(d, 210, 20, '图 13：2x2 窗口取最大值，尺寸减半。', fs=8, color=GRAY)
    return d


def diag_cnn():
    """Ch4：tiny CNN 结构。"""
    d = _diagram(600, 200)
    boxes = [
        ('输入\n28x28x1', 40, LIGHT),
        ('Conv3x3\n->8 + ReLU', 130, LIGHT),
        ('MaxPool\n14x14x8', 220, LIGHT),
        ('Conv3x3\n->16 + ReLU', 310, LIGHT),
        ('MaxPool\n7x7x16', 400, LIGHT),
        ('FC64\nReLU', 470, ORANGE),
        ('FC10\nSoftmax', 520, ORANGE),
    ]
    for name, x, fill in boxes:
        _box(d, x, 70, 55, 70, name, fs=7, fill=fill, stroke=ORANGE)
    for i in range(len(boxes) - 1):
        x1 = boxes[i][1] + 55
        x2 = boxes[i + 1][1]
        _arrow(d, x1, 105, x2, 105)
    _dtext(d, 280, 25, '图 12：tiny CNN = 卷积 + 池化 + 全连接，'
                       '没有检测头/NMS，是 NPU 入门的最佳模型。',
           fs=8, color=GRAY)
    return d


def diag_quant():
    """Ch4：per-tensor 量化。"""
    d = _diagram(540, 200)
    _dtext(d, 40, 150, '浮点权重分布', fs=9, anchor='start')
    for i in range(12):
        h = 20 + (i % 5) * 8
        _box(d, 60 + i * 36, 80, 30, h, '', fs=6, fill=LIGHT,
             stroke=ORANGE)
    _arrow(d, 500, 120, 540, 120, 'scale')
    _dtext(d, 40, 40, '量化后 int8 桶', fs=9, anchor='start')
    for i in range(12):
        _box(d, 60 + i * 36, 20, 30, 25, '', fs=6, fill=ORANGE)
    _dtext(d, 270, 175, '图 13：min/max 确定 scale，整个张量映射到'
                       ' [-128, 127]。', fs=8, color=GRAY)
    return d


def diag_soc():
    """Ch5：Hack + NPU 整机。"""
    d = _diagram(560, 250)
    _box(d, 20, 120, 200, 90, 'Hack Computer\nROM + CPU + Memory',
         fs=10, fill=LIGHT, stroke=ORANGE)
    _box(d, 340, 120, 200, 90, 'NPU 外设\n控制器 + SRAM + 阵列',
         fs=10, fill=LIGHT, stroke=ORANGE)
    _arrow(d, 220, 165, 340, 165, 'MMIO 0x7000+')
    _box(d, 60, 25, 120, 45, 'Hack 驱动\n(轮询)', fs=8)
    _box(d, 220, 25, 120, 45, '命令/状态\n寄存器', fs=8)
    _box(d, 380, 25, 120, 45, '推理结果\n写回 RAM', fs=8)
    _arrow(d, 120, 70, 120, 120)
    _arrow(d, 280, 70, 280, 120)
    _arrow(d, 440, 70, 440, 120)
    _dtext(d, 280, 10, '图 14：NPU 作为内存映射外设挂在 Hack 整机上。',
           fs=8, color=GRAY)
    return d


def diag_handshake():
    """Ch5：CPU-NPU 握手时序。"""
    d = _diagram(540, 240)
    _dtext(d, 120, 205, 'CPU', fs=10)
    _dtext(d, 420, 205, 'NPU', fs=10)
    _arrow(d, 120, 190, 120, 20, '', color=GRAY, lw=1.2)
    _arrow(d, 420, 190, 420, 20, '', color=GRAY, lw=1.2)
    steps = [
        (160, '写 CMD=START', 380),
        (130, 'BUSY=1', 420),
        (100, '计算中 ...', 420),
        (70, 'DONE=1', 420),
        (40, '读 STATUS / 结果', 160),
    ]
    for y, msg, x2 in steps:
        if msg in ('BUSY=1', 'DONE=1'):
            _arrow(d, 420, y + 8, 420, y, '', color=ORANGE)
            _dtext(d, 330, y - 3, msg, fs=8, anchor='end')
        else:
            _arrow(d, 180, y + 8, 380, y, '', color=ORANGE)
            _dtext(d, 280, y + 10, msg, fs=8)
    _dtext(d, 270, 10, '图 15：先写命令，再轮询完成位，最后读结果。',
           fs=8, color=GRAY)
    return d


def diag_binary():
    """Ch0：二进制与位权。"""
    d = _diagram(560, 220)
    _dtext(d, 60, 180, '二进制 10110 = ?', fs=10, anchor='start')
    powers = [16, 8, 4, 2, 1]
    bits = [1, 0, 1, 1, 0]
    for i, (p, b) in enumerate(zip(powers, bits)):
        x = 60 + i * 70
        _box(d, x, 90, 55, 35, str(b), fs=12, fill=ORANGE if b else LIGHT,
             stroke=ORANGE, tc=colors.white if b else DARK)
        _dtext(d, x + 27, 70, 'x%d' % p, fs=8)
    _dtext(d, 60, 30, '= 1x16 + 0x8 + 1x4 + 1x2 + 0x1 = 22',
           fs=10, anchor='start')
    _dtext(d, 280, 200, '图 A：电脑里只有 0 和 1，每一位代表一个“位权”。',
           fs=8, color=GRAY)
    return d


def diag_mul():
    """Ch0：乘法 = 重复加法 / 移位相加。"""
    d = _diagram(560, 220)
    _box(d, 30, 120, 140, 60, '3 x 4\n= 4 + 4 + 4\n= 12', fs=10,
         fill=LIGHT, stroke=ORANGE)
    _box(d, 210, 120, 140, 60, '硬件做法\n3 x 4 = 3 << 2\n= 12', fs=10,
         fill=LIGHT, stroke=ORANGE)
    _box(d, 390, 120, 140, 60, '通用做法\n乘累加：acc += a*w', fs=10,
         fill=LIGHT, stroke=ORANGE)
    _arrow(d, 170, 150, 210, 150)
    _arrow(d, 350, 150, 390, 150)
    _dtext(d, 280, 40, '图 B：乘法看起来简单，但硬件里需要很多门电路；',
           fs=8, color=GRAY)
    _dtext(d, 280, 27, '所以 NPU 把乘法器铺成阵列并行做。', fs=8, color=GRAY)
    return d


def diag_matrix():
    """Ch0/Ch1：2x2 矩阵乘。"""
    d = _diagram(560, 240)
    # A
    _dtext(d, 110, 205, 'A（2x2）', fs=9)
    _box(d, 60, 120, 45, 45, 'a00', fs=9, fill=LIGHT)
    _box(d, 110, 120, 45, 45, 'a01', fs=9, fill=LIGHT)
    _box(d, 60, 70, 45, 45, 'a10', fs=9, fill=LIGHT)
    _box(d, 110, 70, 45, 45, 'a11', fs=9, fill=LIGHT)
    # B
    _dtext(d, 290, 205, 'B（2x2）', fs=9)
    _box(d, 240, 120, 45, 45, 'b00', fs=9, fill=LIGHT)
    _box(d, 290, 120, 45, 45, 'b01', fs=9, fill=LIGHT)
    _box(d, 240, 70, 45, 45, 'b10', fs=9, fill=LIGHT)
    _box(d, 290, 70, 45, 45, 'b11', fs=9, fill=LIGHT)
    # C
    _dtext(d, 470, 205, 'C = A x B', fs=9)
    _box(d, 420, 120, 60, 45, 'a00*b00\n+a01*b10', fs=7, fill=ORANGE,
         stroke=ORANGE, tc=colors.white)
    _box(d, 485, 120, 60, 45, 'a00*b01\n+a01*b11', fs=7, fill=ORANGE,
         stroke=ORANGE, tc=colors.white)
    _box(d, 420, 70, 60, 45, 'a10*b00\n+a11*b10', fs=7, fill=ORANGE,
         stroke=ORANGE, tc=colors.white)
    _box(d, 485, 70, 60, 45, 'a10*b01\n+a11*b11', fs=7, fill=ORANGE,
         stroke=ORANGE, tc=colors.white)
    _arrow(d, 155, 142, 240, 142)
    _arrow(d, 335, 142, 420, 142)
    _dtext(d, 280, 25, '图 C：C 的每个格子 = A 的一行 与 B 的一列 逐项相乘再相加。',
           fs=8, color=GRAY)
    return d


def diag_neuron():
    """Ch0/Ch4：神经元 = 加权求和 + 激活。"""
    d = _diagram(560, 240)
    xs = [(60, 160, 'x1'), (60, 110, 'x2'), (60, 60, 'x3')]
    for x, y, lab in xs:
        _box(d, x, y, 50, 35, lab, fs=9, fill=LIGHT)
    _box(d, 320, 105, 90, 60, '求和\n+ bias', fs=9, fill=ORANGE,
         stroke=ORANGE, tc=colors.white)
    _box(d, 460, 105, 70, 60, 'ReLU\nmax(0,z)', fs=9, fill=LIGHT)
    for i, (x, y, lab) in enumerate(xs):
        _arrow(d, x + 50, y + 17, 320, y + 17,
               'w%d' % (i + 1), fs=7)
    _arrow(d, 410, 135, 460, 135, 'z')
    _dtext(d, 495, 90, 'y', fs=10)
    _dtext(d, 280, 210, '图 D：神经元把输入分别乘以权重、加总、再加偏置，'
                        '最后过一个激活函数。', fs=8, color=GRAY)
    return d


def diag_conv():
    """Ch0/Ch3：卷积 = 滑动窗口加权求和。"""
    d = _diagram(560, 260)
    _dtext(d, 110, 230, '输入 5x5', fs=9)
    for i in range(5):
        for j in range(5):
            _box(d, 40 + j * 34, 60 + i * 34, 32, 32, '', fs=6,
                 fill=colors.white, stroke=ORANGE)
    for i in range(3):
        for j in range(3):
            _box(d, 74 + j * 34, 60 + i * 34, 32, 32, '', fs=6,
                 fill=LIGHT, stroke=ORANGE, lw=2)
    _arrow(d, 230, 130, 290, 130, '乘加')
    _dtext(d, 400, 230, '卷积核 3x3', fs=9)
    for i in range(3):
        for j in range(3):
            _box(d, 360 + j * 30, 150 + i * 30, 28, 28, 'w', fs=7,
                 fill=ORANGE, stroke=ORANGE, tc=colors.white)
    _dtext(d, 420, 130, '输出 3x3', fs=9)
    for i in range(3):
        for j in range(3):
            _box(d, 380 + j * 40, 20 + i * 40, 38, 38, 'y', fs=8,
                 fill=LIGHT, stroke=ORANGE)
    _dtext(d, 280, 10, '图 E：卷积核像手电筒一样在图片上滑动，'
                       '每滑到一个位置就做一次加权求和。', fs=8, color=GRAY)
    return d


def diag_memory():
    """Ch0/Ch1：内存 = 带编号的格子。"""
    d = _diagram(420, 240)
    rows = [('地址 0', '数据 15'), ('地址 1', '数据 32'),
            ('地址 2', '数据 7'), ('地址 3', '数据 255')]
    for i, (a, v) in enumerate(rows):
        _box(d, 50, 150 - i * 40, 120, 35, a, fs=9, fill=LIGHT)
        _box(d, 190, 150 - i * 40, 160, 35, v, fs=9, fill=ORANGE,
             stroke=ORANGE, tc=colors.white)
    _dtext(d, 70, 40, 'CPU 说“给我地址 2 的内容”，', fs=9, anchor='start')
    _dtext(d, 70, 25, '内存就返回 7。', fs=9, anchor='start')
    _dtext(d, 210, 205, '图 F：地址像门牌号，数据像屋里的人。',
           fs=8, color=GRAY)
    return d


def diag_bus():
    """Ch0/Ch1：总线把 CPU、内存、外设连起来。"""
    d = _diagram(540, 220)
    _box(d, 30, 90, 120, 60, 'CPU', fs=10, fill=LIGHT, stroke=ORANGE)
    _box(d, 210, 90, 120, 60, '内存', fs=10, fill=LIGHT, stroke=ORANGE)
    _box(d, 390, 90, 120, 60, '外设(NPU)', fs=10, fill=LIGHT, stroke=ORANGE)
    _arrow(d, 150, 120, 210, 120)
    _arrow(d, 330, 120, 390, 120)
    _box(d, 90, 15, 360, 35, '总线：地址线 + 数据线 + 控制线',
         fs=9, fill=LIGHT)
    _arrow(d, 180, 50, 180, 90)
    _arrow(d, 360, 50, 360, 90)
    _dtext(d, 270, 195, '图 G：所有设备都挂在同一条“马路”上，'
                        '用地址区分找谁。', fs=8, color=GRAY)
    return d


DIAGRAMS = {
    'binary': diag_binary,
    'mul': diag_mul,
    'matrix': diag_matrix,
    'neuron': diag_neuron,
    'conv': diag_conv,
    'memory': diag_memory,
    'bus': diag_bus,
    'system': diag_system,
    'addr_map': diag_addr_map,
    'mmio_flow': diag_mmio_flow,
    'int8': diag_int8,
    'pe': diag_pe,
    'array': diag_array,
    'skew': diag_skew,
    'align': diag_align,
    'timing': diag_timing,
    'sram': diag_sram,
    'linebuffer': diag_linebuffer,
    'fsm': diag_fsm,
    'im2col': diag_im2col,
    'pool': diag_pool,
    'cnn': diag_cnn,
    'quant': diag_quant,
    'export': diag_export,
    'soc': diag_soc,
    'handshake': diag_handshake,
    'driver': diag_driver,
}


GLOSSARY = [
    ('CPU', '中央处理器，负责执行指令；在本课程里是 Hack CPU。'),
    ('RAM', '随机存取存储器，Hack 有 64KB，用于放数据和程序状态。'),
    ('MMIO', 'Memory-Mapped I/O，把外设寄存器映射到内存地址，CPU 用普通读写指令控制外设。'),
    ('寄存器', 'CPU 或外设内部的小容量存储单元，通常 8/16/32 位。'),
    ('SRAM', '片上静态随机存储器，速度快、容量小，NPU 用它暂存权重和特征图。'),
    ('MAC', '乘累加运算：acc = acc + a * w，是 CNN 最基础的计算。'),
    ('GEMM', '通用矩阵乘，C = A x B；卷积可以转换成 GEMM。'),
    ('PE', 'Processing Element，处理单元；本课程里是一个 MAC 单元。'),
    ('Systolic Array', '脉动阵列：PE 排成网格，数据在相邻 PE 间逐拍流动。'),
    ('Weight-Stationary', '权重驻留式数据流：权重装载后停在 PE 内反复使用。'),
    ('斜输入', '把第 row 行输入延迟 row 拍，使阵列各行在同一拍处理同一个 k。'),
    ('im2col', 'Image to Column，把卷积窗口展平成矩阵行，从而用 GEMM 计算卷积。'),
    ('Line Buffer', '行缓冲：只保留最近若干行，供滑动窗口复用。'),
    ('FSM', '有限状态机：一组状态和跳转条件，NPU 控制器用它实现调度。'),
    ('DMA', 'Direct Memory Access，直接内存访问，批量搬运数据。'),
    ('量化', '把浮点数映射到低比特整数（如 int8），并记录 scale 以便还原。'),
    ('Scale', '量化比例因子，决定一个整数单位代表多大的浮点数值。'),
    ('Polling', '轮询：CPU 反复读状态寄存器，直到外设完成。'),
    ('argmax', '取最大值的下标；分类任务里就是预测类别。'),
    ('NPU', 'Neural Processing Unit，神经网络处理器，专为张量运算设计的加速器。'),
]


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
                               'Page %d' % doc.page)
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
        for para in slide.get('body', []):
            story.append(Paragraph(para, st['slide_body']))
            story.append(Spacer(1, 0.2 * cm))
        for b in slide['bullets']:
            story.append(Paragraph('&bull;&nbsp; ' + b, st['slide_bullet']))
        for diag_name in slide.get('diagrams', []):
            story.append(Spacer(1, 0.35 * cm))
            story.append(DIAGRAMS[diag_name]())
        if slide.get('cite'):
            story.append(Spacer(1, 0.3 * cm))
            story.append(Paragraph('Paper: ' + slide['cite'], st['hint']))
        if slide.get('note'):
            story.append(Spacer(1, 0.3 * cm))
            story.append(Paragraph('Note: ' + slide['note'], st['hint']))

    story.append(PageBreak())
    story.append(Paragraph('术语速查（Glossary）', st['slide_title']))
    story.append(Spacer(1, 0.5 * cm))
    for term, desc in GLOSSARY:
        story.append(Paragraph('&bull;&nbsp; <b>%s</b>：%s' % (term, desc),
                               st['slide_bullet']))

    if lec.get('refs'):
        story.append(PageBreak())
        story.append(Paragraph('References / 延伸阅读', st['slide_title']))
        story.append(Spacer(1, 0.5 * cm))
        for ref in lec['refs']:
            story.append(Paragraph('&bull;&nbsp; ' + ref, st['slide_bullet']))

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

    # 作业内容说明（可选）：以后每章的 assignment 都应提供 'content'，
    # 把作业涉及的模块/接口/时序/验证方法讲清楚，而不是只有书面题。
    content = a.get('content')
    if content:
        story.append(Paragraph('作业内容说明', st['h1']))
        for sec in content:
            story.append(Paragraph(sec['title'], st['h2']))
            if 'body' in sec:
                story += [Paragraph(x, st['body']) for x in sec['body']]
            if 'bullets' in sec:
                story += bullets(st, sec['bullets'])
            if 'table' in sec:
                cols = len(sec['table'][0])
                widths = sec.get('colWidths') or [16.6 / cols] * cols
                tbl = Table(sec['table'], colWidths=[float(w) * cm for w in widths])
                tbl.setStyle(TableStyle([
                    ('FONTNAME', (0, 0), (-1, -1), FONT),
                    ('BACKGROUND', (0, 0), (-1, 0), ORANGE),
                    ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
                    ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#CCCCCC')),
                    ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, LIGHT]),
                    ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                    ('LEFTPADDING', (0, 0), (-1, -1), 5),
                    ('RIGHTPADDING', (0, 0), (-1, -1), 5),
                    ('TOPPADDING', (0, 0), (-1, -1), 4),
                    ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
                ]))
                story.append(tbl)
                if sec.get('note'):
                    story.append(Paragraph('注：' + sec['note'], st['hint']))
            story.append(Spacer(1, 0.2 * cm))

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
        'num': 0,
        'title': '预备知识：从二进制到矩阵',
        'en_title': 'Prerequisites: From Binary to Matrix',
        'project': {
            'background': [
                '这一章不写代码，也不碰 Verilog。它的任务是把后面所有章节需要的基础概念，'
                '用最直白的方式讲清楚：二进制、内存、CPU、乘法、矩阵、神经网络、卷积、'
                '总线和 MMIO。',
                '如果你从来没有接触过计算机组成，请务必先读完这一章。后面的每一章都会'
                '假设你已经理解这些词。',
            ],
            'objective': [
                '能独立完成二进制和十进制互换算。',
                '能解释“地址”和“数据”的区别。',
                '能手算 2x2 矩阵乘法。',
                '能用一句话解释什么是 MMIO。',
                '能说出 CPU 为什么不适合做 CNN 计算。',
            ],
            'deliverables': [
                '一份手写/电子版概念自测表（10 个问题）。',
                '至少 5 个术语用自己的话写解释。',
                '2x2 矩阵乘法的完整手算过程。',
            ],
            'contract': [
                '每个概念都能不看讲义、用自己的话讲出来。',
                '所有计算题结果正确，且写清步骤。',
                '能向同桌解释：为什么 NPU 比 CPU 更适合算矩阵。',
            ],
            'resources': [
                '本仓库 `docs/npu/course/Chapter00/Lecture.pdf`。',
                'nand2tetris.org 的 Chapter 1（Boolean Logic）作为扩展阅读。',
                'Khan Academy 的二进制与矩阵乘法视频（可选）。',
            ],
            'tips': [
                '遇到不懂的术语，先想一个生活中的类比，再对照讲义。',
                '不要背概念，要做题：二进制转换、矩阵乘法、卷积输出尺寸。',
                '这一章可以随时回头翻，它不是一次性的。',
            ],
        },
        'lecture': {
            'slides': [
                {'title': '欢迎：这门课会带你去哪', 'bullets': [
                    '我们要从一个只有 0 和 1 的世界，搭出一个能认数字的 NPU。',
                    '路上会用到：二进制、内存、CPU、矩阵、神经网络、卷积。',
                    '这一章先把这些词变成你熟悉的东西。',
                ]},
                {'title': '电脑里只有 0 和 1', 'body': [
                    '所有电子设备内部只有两种状态：有电/没电，通常写成 1 和 0。'
                    '图片、声音、文字，最终都变成一串 0 和 1。',
                    '一个 0 或 1 叫一个 bit（比特）；8 个 bit 叫一个 byte（字节）。'
                    'int8 的意思就是“用 8 个 bit 表示一个整数”。',
                ], 'bullets': [
                    'bit = 一位二进制，只能是 0 或 1。',
                    'byte = 8 个 bit。',
                    'int8 = 8 位有符号整数，范围 -128 到 127。',
                ], 'diagrams': ['binary']},
                {'title': '二进制怎么算', 'body': [
                    '十进制每一位代表 10 的几次方：个位、十位、百位。'
                    '二进制每一位代表 2 的几次方：1、2、4、8、16...',
                    '比如 10110 = 1x16 + 0x8 + 1x4 + 1x2 + 0x1 = 22。'
                    '反过来，22 = 16+4+2 = 10110。',
                ], 'bullets': [
                    '从右往左数：第 0 位是 1，第 1 位是 2，第 2 位是 4...',
                    '把位上是 1 的位权加起来就是十进制。',
                    '后面所有“int8 权重”都按这个规则理解。',
                ], 'diagrams': ['binary']},
                {'title': '内存：带编号的格子', 'body': [
                    '把内存想象成一排带门牌号的储物柜。地址（address）是门牌号，'
                    '数据（data）是柜子里放的东西。',
                    'CPU 说“读地址 2”，内存就把 2 号柜子里的值还给它；'
                    'CPU 说“写地址 3，内容 7”，内存就把 3 号柜子改成 7。',
                ], 'bullets': [
                    '地址 = 位置编号。',
                    '数据 = 存在这个位置的值。',
                    'Hack 有 32K 个 16 位格子，共 64KB。',
                ], 'diagrams': ['memory']},
                {'title': 'CPU：听指令做事的工人', 'body': [
                    'CPU 是一个“只会按说明书干活”的工人。说明书就是程序，'
                    '程序里每一条都是指令，比如“把 A 的值加 1”。',
                    'CPU 的工作循环是：取指令 -> 看懂它 -> 执行它 -> 取下一条。'
                    '这个循环叫“取指-译码-执行”。',
                ], 'bullets': [
                    '程序 = 指令的列表。',
                    '指令 = 让 CPU 做一件小事。',
                    'Hack 的 ALU 只会加减法和按位运算。',
                ]},
                {'title': '乘法为什么贵', 'body': [
                    '3 x 4 可以看成 4+4+4。硬件里乘法确实可以用“移位+加法”实现，'
                    '但每一位都要一堆门电路，位数越多越贵。',
                    'CNN 要做几万到几亿次乘法。如果 CPU 一次只能做一个，'
                    '就会慢得离谱。NPU 的思路是：把很多乘法器同时铺开。',
                ], 'bullets': [
                    '乘法 = 重复加法 / 移位相加。',
                    '一个乘法器不贵，几万个乘法器一起干活才快。',
                    '这就是“并行”的朴素含义。',
                ], 'diagrams': ['mul']},
                {'title': '矩阵：数字表格', 'body': [
                    '矩阵就是一张数字表格。比如 2x2 矩阵有 2 行 2 列。'
                    '一张 28x28 的灰度图片，也可以看成 28 行 28 列的数字表格。',
                    '神经网络里的权重通常也组织成矩阵，所以“算神经网络”'
                    '很大程度就是“算矩阵”。',
                ], 'bullets': [
                    '矩阵 = 有行有列的数字表格。',
                    '图片 = 数字表格。',
                    '权重 = 数字表格。',
                    '卷积/全连接最终都变成矩阵运算。',
                ], 'diagrams': ['matrix']},
                {'title': '矩阵乘法', 'body': [
                    'C = A x B 时，C 的第 i 行第 j 列 = A 的第 i 行 与 B 的第 j 列'
                    '逐项相乘再相加。',
                    '比如 C[0][0] = a00*b00 + a01*b10。每一个这样的“乘加”'
                    '就是一个 MAC。矩阵乘法的计算量 = 所有 MAC 的数量。',
                ], 'bullets': [
                    'MAC = 一次乘 + 一次加。',
                    '矩阵乘法 = 一堆 MAC。',
                    'NPU 的脉动阵列就是让这些 MAC 并行发生。',
                ], 'diagrams': ['matrix']},
                {'title': '神经网络：加权求和', 'body': [
                    '一个神经元做的事：把每个输入 x 乘上权重 w，全部加起来，'
                    '再加一个偏置 b，最后过激活函数（比如 ReLU：负数变 0）。',
                    '很多个神经元叠在一起，就组成神经网络。训练就是不断调整'
                    '这些权重，让输出接近正确答案。',
                ], 'bullets': [
                    'z = w1*x1 + w2*x2 + w3*x3 + b。',
                    'ReLU：如果 z 小于 0，就输出 0。',
                    '推理 = 用已经训练好的权重做这些计算。',
                ], 'diagrams': ['neuron']},
                {'title': '卷积：滑动窗口', 'body': [
                    '卷积就是“用一个小窗口（卷积核）在图片上滑动，每到一个位置'
                    '做一次加权求和”。',
                    '5x5 图片 + 3x3 卷积核、stride=1、无 padding，输出是 3x3。'
                    '公式：输出边长 = 输入边长 - 核边长 + 1。',
                ], 'bullets': [
                    '卷积核 = 小窗口 + 一组权重。',
                    '滑动一步叫 stride。',
                    '卷积能提取图片里的局部特征。',
                ], 'diagrams': ['conv']},
                {'title': '为什么要硬件加速', 'body': [
                    '假设一层卷积要做 10 万次 MAC。CPU 一次做一个，需要 10 万步；'
                    '如果有 8x8=64 个乘法器同时做，理想情况下只要约 1563 步。',
                    '硬件加速的本质就是：把“一个乘法器重复用很多次”'
                    '改成“很多乘法器同时用”。',
                ], 'bullets': [
                    '串行：一次一个 MAC。',
                    '并行：64 个 MAC 同时发生。',
                    'NPU = 为并行 MAC 设计的专用硬件。',
                ]},
                {'title': '总线：把设备连起来', 'body': [
                    'CPU、内存、外设都挂在同一条“马路”上，这条马路叫总线。'
                    '总线里有地址线（说找谁）、数据线（传内容）、控制线（说读写）。',
                    'MMIO 就是让外设也在这条马路上有一个门牌号。',
                ], 'bullets': [
                    '总线 = 地址线 + 数据线 + 控制线。',
                    '每个设备有唯一地址段。',
                    'CPU 读写外设和读写内存用的是同一种指令。',
                ], 'diagrams': ['bus']},
                {'title': 'MMIO：把外设当内存', 'body': [
                    'Memory-Mapped I/O 的意思是：外设的寄存器也有地址。'
                    'CPU 往“0x7000”这个地址写 1，NPU 就知道“开始干活”。',
                    '对 CPU 来说，控制 NPU 和控制 RAM 没区别：都是读地址、写地址。'
                    '对 NPU 来说，它只是发现“有人在我的地址上读写”。',
                ], 'bullets': [
                    '寄存器 = 外设身上的小格子。',
                    'MMIO = 给这些小格子发门牌号。',
                    'CPU 写命令、轮询状态，都是普通内存指令。',
                ]},
                {'title': 'NPU 是什么', 'body': [
                    'NPU（Neural Processing Unit）是专门算神经网络的外设。'
                    '它内部有：命令/状态寄存器、存放权重和数据的 SRAM、'
                    '一排排乘法器（脉动阵列）、控制这些部件的小状态机。',
                    'CPU 负责“指挥”，NPU 负责“埋头算”。',
                ], 'bullets': [
                    'NPU = 神经网络加速器。',
                    'CPU 调度，NPU 计算。',
                    '本课程要从零把 NPU 搭出来。',
                ]},
                {'title': '本课程地图', 'bullets': [
                    'Ch1：定系统架构和 MMIO 协议。',
                    'Ch2：做 PE 和脉动阵列。',
                    'Ch3：做控制器和卷积数据通路。',
                    'Ch4：训练并量化一个小模型。',
                    'Ch5：挂进 Hack 整机，端到端推理。',
                ]},
                {'title': '你需要掌握的词汇', 'bullets': [
                    'bit / byte / int8。',
                    '地址 / 数据 / 寄存器。',
                    '指令 / 程序 / CPU。',
                    'MAC / 矩阵 / 卷积。',
                    '总线 / MMIO / NPU。',
                ]},
                {'title': '本章作业', 'bullets': [
                    '完成 Assignment.pdf 的 10 道题。',
                    '用手算完成 2x2 矩阵乘法。',
                    '用自己的话写 5 个术语解释。',
                    '向朋友解释一次“MMIO 是什么”。',
                ]},
                {'title': '总结', 'bullets': [
                    '电脑只有 0 和 1，但可以表达一切。',
                    '内存是格子，地址是门牌号。',
                    '神经网络 = 大量加权求和。',
                    'NPU 把 MAC 并行化，CPU 只负责指挥。',
                    '下一章开始设计系统架构。',
                ]},
            ],
            'refs': [
                'Khan Academy: Binary numbers（二进制入门）.',
                'Khan Academy: Matrix multiplication（矩阵乘法入门）.',
                'Patterson & Hennessy, Computer Organization and Design（概念参考）.',
            ],
        },
        'assignment': {
            'intro': [
                '这一章的作业不写代码，只做概念题和手算题。'
                '每题都要写清过程，不要只写答案。',
            ],
            'questions': [
                {'q': '把二进制 10110 转换成十进制，写出每一位的位权。',
                 'hint': '从右往左：1、2、4、8、16。'},
                {'q': '把十进制 22 转换成二进制。',
                 'hint': '22 = 16 + 4 + 2。'},
                {'q': '用自己的话解释“地址”和“数据”的区别，并举例。',
                 'hint': '储物柜的门牌号和柜子里的东西。'},
                {'q': '为什么 3 x 4 可以用“3 左移 2 位”实现？写出过程。',
                 'hint': '4 = 2^2，左移一位相当于乘 2。'},
                {'q': '手算矩阵乘法：[[1,2],[3,4]] x [[5,6],[7,8]]，写出每个输出格子的计算过程。',
                 'hint': 'C[0][0] = 1*5 + 2*7。'},
                {'q': '一个神经元有 3 个输入：x=[2,-1,0.5]，w=[0.5,1,-2]，b=1。计算 z 和 ReLU(z)。',
                 'hint': 'z = 2*0.5 + (-1)*1 + 0.5*(-2) + 1。'},
                {'q': '5x5 输入、3x3 卷积核、stride=1、无 padding，输出尺寸是多少？',
                 'hint': '输出 = 输入 - 核 + 1。'},
                {'q': '用一句话解释 MMIO。',
                 'hint': '外设寄存器 = 内存地址。'},
                {'q': '为什么 CPU 不适合做 CNN 推理？给出两个理由。',
                 'hint': '指令开销 + 乘法器数量。'},
                {'q': '从术语表里选 5 个词，用你自己的话各写一句解释。',
                 'hint': '能讲给同学听才算懂。'},
            ],
            'submission': [
                '10 道题的完整解答。',
                '5 个自选术语解释。',
            ],
            'rubric': [
                ('二进制换算正确', 15),
                ('内存/地址概念解释清楚', 15),
                ('矩阵乘法手算正确', 20),
                ('神经元计算正确', 15),
                ('卷积输出尺寸正确', 15),
                ('MMIO 一句话解释到位', 10),
                ('术语自解释', 10),
            ],
        },
    },
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
                '实现 `n2t_shift_register`：参数化移位寄存器，用于斜输入与输出对齐。',
                '实现 `n2t_pe`：int8 x int8 + int32 累加的 MAC 单元。',
                '实现 `n2t_systolic_array`：参数化 N x N 脉动阵列，支持批量权重装载、斜输入和输出对齐。',
                '理解阵列语义：C[k][col] = sum_row A[row][k] * W[row][col]。',
            ],
            'deliverables': [
                '`assignment/06/ShiftRegister.v`：完成后的移位寄存器。',
                '`assignment/06/PE.v`：完成后的 PE。',
                '`assignment/06/SystolicArray.v`：完成后的阵列。',
                '运行 `make sim-06` 得到全部 PASS。',
            ],
            'contract': [
                'ShiftRegister：`en=1` 时每个 posedge 右移一级，`out` 延迟 DEPTH 拍。',
                'PE：psum_out = psum_in + a_in * w，全部使用有符号运算。',
                '阵列：`w_data` 为 N*N*W_W 位，`a_data` 为 N*A_W 位，`psum_out` 为 N*P_W 位。',
                '时序：使用正规上升沿（posedge）提交，与真实 FPGA 一致。',
                '测试：ShiftRegister 9 项（含 DEPTH=0 直通）、PE 6 项、SystolicArray 64 项检查全部通过。',
            ],
            'resources': [
                '`docs/npu.md`：数据布局、时序约定。',
                '`solution/06/ShiftRegister.v`、`PE.v` 与 `SystolicArray.v`：参考实现。',
                '`tb/06/ShiftRegister_tb.v`、`PE_tb.v` 与 `SystolicArray_tb.v`：测试台。',
            ],
            'tips': [
                '先做移位寄存器，理解延迟 DEPTH 拍的含义，再做阵列的斜输入/输出对齐。',
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
            'content': [
                {'title': '模块总览',
                 'bullets': [
                     '本章仓库提供三个模块，模板在 `assignment/06/`，参考实现在 `solution/06/`：',
                     '`n2t_shift_register`：参数化移位寄存器，用于斜输入与输出对齐；',
                     '`n2t_pe`：单 PE，int8 x int8 + int32 累加；',
                     '`n2t_systolic_array`：N x N weight-stationary 脉动阵列，内部例化上面两个模块。',
                     '对应测试台：`tb/06/ShiftRegister_tb.v`、`PE_tb.v`、`SystolicArray_tb.v`。',
                 ]},
                {'title': '端口要点',
                 'table': [
                     ['模块', '关键端口/参数', '行为'],
                     ['ShiftRegister', 'clk/arst/en/in/out；DEPTH 参数', 'en=1 时每拍移入，out 延迟 DEPTH 拍；DEPTH=0 直通'],
                     ['PE', 'w_load/w_in/a_in/psum_in；A_W/W_W/P_W', 'w_load 时写入权重；psum_out = psum_in + a_in*w（有符号）'],
                     ['SystolicArray', 'w_load/w_data/a_data/psum_out；N/A_W/W_W/P_W', 'w_data 行主序 N*N*W_W；每拍送一个 N 通道向量；行 i 输入延迟 i 拍；底部按列对齐输出'],
                 ],
                 'colWidths': [2.8, 5.4, 8.4]},
                {'title': '时序契约',
                 'bullets': [
                     'w_load 高电平批量装载权重（1 拍）；之后每拍送一个 a_data 向量；',
                     '最后一个输入送入后再等 N-1 拍，开始逐拍输出；第 col 列额外延迟 N-1-col 拍对齐。',
                     '总周期数 ≈ 装载 1 拍 + 输入 N 拍 + 排空 2N-2 拍。',
                     '端口全部 posedge，异步复位 arst 高有效。',
                 ]},
                {'title': '验证方法',
                 'bullets': [
                     '运行 `make sim-06`（学生模式）或 `make sim-06 RTLDIR=solution`（答案回归）。',
                     'ShiftRegister 覆盖 DEPTH=0 直通与多级延迟；PE 覆盖正负权重/激活；SystolicArray 用 8x8 矩阵乘验证 C[k][col] = sum_row A[row][k]*W[row][col]。',
                     '常见错误：忘记 signed 导致负数乘法错；w_data 位宽写成 N*W_W；复位不完整导致初值 x 传播。',
                 ]},
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
                '完成后的 ShiftRegister.v、PE.v 与 SystolicArray.v。',
                '`make sim-06` 的 PASS 输出。',
                'Q1-Q5 书面回答（含手工时序表）。',
            ],
            'rubric': [
                ('ShiftRegister 实现正确', 15),
                ('PE 实现正确', 15),
                ('SystolicArray 实现正确', 30),
                ('make sim-06 全部 PASS', 20),
                ('手工时序表正确', 10),
                ('书面推导完整', 10),
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
                '保持 posedge 时序约定。',
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
            'content': [
                {'title': '模块总览',
                 'bullets': [
                     '本章仓库新增三个模块，模板在 `assignment/07/`，参考实现在 `solution/07/`：',
                     '`n2t_relu`：量化域 ReLU，out = max(in, 0)，纯组合逻辑，零乘法；',
                     '`n2t_maxpool`：MaxPool 2x2，四个 int8 取最大，只用比较器；',
                     '`n2t_conv_unit`：3x3 卷积控制器 + 数据通路，例化第 2 章的 `n2t_systolic_array` 作为计算核心。',
                     '对应测试台：`tb/07/ReLU_tb.v`、`MaxPool_tb.v`、`ConvUnit_tb.v`。',
                 ]},
                {'title': 'ConvUnit 参数与端口',
                 'body': [
                     '框架默认 C_IN=C_OUT=4（阵列 N=4）以控制 iverilog 仿真时间；把参数调成 8 即复用 8x8 阵列，逻辑不变。',
                 ],
                 'table': [
                     ['参数', '默认', '说明'],
                     ['H / W', '8 / 8', '输入特征图高/宽'],
                     ['C_IN / C_OUT', '4 / 4', '输入/输出通道（须等于阵列 N）'],
                     ['K', '3', '卷积核尺寸'],
                     ['STRIDE / PAD', '1 / 0', '支持 stride=1/2、pad=0/1'],
                     ['A_W / W_W / P_W', '8 / 8 / 32', '激活/权重/累加位宽（有符号）'],
                 ],
                 'colWidths': [3.0, 2.2, 11.4],
                 'note': '阵列延迟 LAT = 2*(N-1) 拍（本框架 N=4 时为 6 拍）。'},
                {'title': 'ConvUnit 端口',
                 'table': [
                     ['端口', '方向', '说明'],
                     ['clk / arst', '时钟/复位', 'posedge；异步复位，高有效'],
                     ['wr_ifmap', 'in', '装载特征图：为 1 时每拍写入一个像素'],
                     ['ifmap_in', 'in', '一个像素的 C_IN 个通道（int8）'],
                     ['w_data', 'in', '扁平权重 W[oc][ic][ky][kx]，start 时整体写入'],
                     ['start', 'in', '特征图装载完成后启动一次推理'],
                     ['out_data', 'out', '一拍一个输出像素的 C_OUT 个通道'],
                     ['out_valid / done', 'out', '输出有效 / 整幅图推理完成（脉冲一拍）'],
                 ],
                 'colWidths': [3.0, 2.2, 11.4]},
                {'title': '计算语义',
                 'bullets': [
                     'out[oy][ox][oc] = relu_clamp( sum_{ky,kx,ic} ifmap[oy*STRIDE+ky-PAD][ox*STRIDE+kx-PAD][ic] * W[oc][ic][ky][kx] )',
                     '窗口越界按 0 补齐；relu_clamp(x) = (x<0) ? 0 : (x>127 ? 127 : x)。',
                     '3x3xC_IN 的 im2col 行长度 9*C_IN 超过阵列宽度，按 (ky,kx) 拆成 9 个 tap；',
                     '每个 tap 是一次 C_IN x C_OUT GEMM，外部 int32 累加器跨 tap 累加，得到一个输出像素的所有输出通道。',
                 ]},
                {'title': '时序与状态机',
                 'bullets': [
                     'FSM：IDLE -> LOAD_W -> RUN -> DRAIN -> EMIT -> DONE。',
                     'IDLE：wr_ifmap=1 期间逐拍装载特征图；start 后进入 LOAD_W。',
                     'LOAD_W：拉高 w_load 两拍，把第 tap 个权重矩阵写入阵列。',
                     'RUN：逐拍送 OPIX 个输入向量并收集输出；控制器用 warmup=LAT+1 跳过阵列填充期的无效输出，保证累加索引对齐。',
                     '每个 tap 送完后补 FLUSH 个 0 冲掉流水，否则上一 tap 残留在阵列里的激活会污染下一 tap。',
                     'DRAIN：pending==0（本 tap 全部结果收完、流水已清）后切下一个 tap。',
                     'EMIT：逐拍输出 relu_clamp 后的像素（out_valid=1）；DONE：done 脉冲一拍，回 IDLE。',
                 ]},
                {'title': '验证方法',
                 'bullets': [
                     'golden 内嵌在 testbench 中（int8 整数运算，避免浮点误差），与 RTL 逐元素比对。',
                     'ConvUnit_tb 四组配置并行：stride=1/pad=0（36 像素）、stride=1/pad=1（64 像素）、stride=2/pad=0（9 像素）、stride=2/pad=1（16 像素），共 125 项检查。',
                     '运行：`make sim-07`（学生模式，只跑 NPU 三题）；`make sim-07 RTLDIR=solution`（答案回归，含 posedge Hack 已知库）。',
                     '全连接层 = ConvUnit 配 K=1：没有滑动窗口，直接逐拍喂输入向量，复用同一套控制器与阵列。',
                     '常见错误：忘记 signed 导致负数乘法错；tap 之间不冲流水；累加器不复位；warmup 错一拍导致输出整体平移。',
                 ]},
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
                '扩展 `n2t_memory_posedge` / `n2t_computer_posedge`：在 0x7000-0x7FFF 增加 NPU MMIO。',
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


# ---------------------------------------------------------------------------
# 讲义“详细讲解”补充：按 (章号, 幻灯片标题) 追加正文、配图和论文引用
# ---------------------------------------------------------------------------
LECTURE_NOTES = {
    1: {
        '为什么 CPU 跑不动 CNN': {
            'body': [
                '计算机执行程序时，CPU 一条一条地“取指令 -> 译码 -> 执行”。'
                'Hack 的 ALU 只会做加法、按位与、取反等操作，没有乘法指令；'
                '一个乘累加（a*w+b）在 Hack 上要拆成很多条加法/移位指令，'
                '速度会非常慢。',
                '更关键的是，CNN 的运算量是几万到几亿次 MAC。如果每个 MAC 都要'
                '经过“取指-译码-执行”，指令流本身就变成瓶颈。专用硬件可以把'
                '很多 MAC 放在同一个时钟周期里并行完成。',
            ],
        },
        '系统分层': {
            'body': [
                'MMIO（Memory-Mapped I/O）的意思是：外设的寄存器和内存使用同一条'
                '地址总线。CPU 不需要新的专用指令，只要“往某个地址写值”或“从'
                '某个地址读值”，就能控制外设。',
                '比如地址 0x7000 可以定义为“命令寄存器”，CPU 执行 `@0x7000; M=D`'
                '就把 D 的内容写给了 NPU。对 CPU 来说，这跟写 RAM 没有区别；'
                '对 NPU 来说，它看到地址落在自己的区间，就接管这次读写。',
            ],
            'diagrams': ['system'],
        },
        'NPU 内部结构': {
            'body': [
                'NPU 不是一块“魔法芯片”，它内部也是寄存器、SRAM 和运算阵列的组合。'
                '命令寄存器告诉它“做什么”，状态寄存器告诉 CPU“做完没有”，'
                '权重 SRAM 存放模型参数，输入/输出 SRAM 存放特征图。',
                '脉动阵列只负责最重的矩阵乘；周围这些“搬运工”决定了阵列能不能'
                '吃饱。这也是为什么真实 NPU 设计里 DMA 和缓存往往比阵列本身更难。',
            ],
        },
        'MMIO 协议': {
            'body': [
                '一次最简单的 MMIO 交互分三步：第一，CPU 把输入数据地址、输出'
                '地址、层参数写进 NPU 的寄存器；第二，CPU 向 CMD 寄存器写 START；'
                '第三，CPU 反复读 STATUS 寄存器，直到 DONE 位置 1，再读取结果。',
                '寄存器表就是 CPU 与 NPU 之间的“合同”：地址、位宽、读写方向、'
                '含义都必须提前定好。寄存器表不清楚，后面写驱动时就会互相猜。',
            ],
            'diagrams': ['addr_map', 'mmio_flow'],
            'cite': 'Patterson & Hennessy, Computer Organization and Design, '
                    'memory-mapped I/O 章节',
        },
        '为什么是 int8': {
            'body': [
                '浮点数（float32）做乘法需要很大的硬件，int8 乘法器只有它几分之一'
                '的面积和功耗。NPU 通常把权重和激活量化成 8 位有符号整数，'
                '累加时用 32 位，保证精度。',
                '量化不是“随便取整”：每层有一个 scale，把浮点区间映射到'
                '[-128, 127]。这个映射关系会在 Ch4 详细讲。',
            ],
            'diagrams': ['int8'],
        },
        'GEMM 是核心算子': {
            'body': [
                'GEMM（General Matrix Multiply）是 C = A x B。卷积可以通过 im2col'
                '变成矩阵乘，全连接本来就是矩阵乘。所以只要硬件把矩阵乘做快，'
                'CNN 的大部分计算就快起来了。',
                '脉动阵列正是为 GEMM 设计的：它把乘法器排成网格，让数据像心跳一样'
                '在 PE 之间流动，从而在一个周期内完成很多 MAC。',
            ],
            'cite': 'Kung, Why Systolic Architectures?, IEEE Computer, 1982',
        },
        '数据流总览': {
            'body': [
                '端到端的数据流是：图片从 RAM 拷到输入 SRAM，权重从权重 SRAM 装载'
                '进阵列；控制器逐像素把数据送进阵列，阵列输出经过激活/池化后写回'
                '输出 SRAM；最后一层结束后，CPU 把结果读回 RAM。',
                '这条路径上的每一步都是后面章节的作业：Ch2 做阵列，Ch3 做控制器，'
                'Ch4 做权重，Ch5 做整机。',
            ],
            'diagrams': ['system'],
        },
    },
    2: {
        'PE 接口': {
            'body': [
                'PE 是最小的计算单元，只做一件事：psum_out = psum_in + a * w。'
                'a 是激活，w 是权重，psum 是“部分和”——上一排算到一半的结果。',
                '数据流的方向很重要：a 从西边进来、从东边出去；psum 从北边进来、'
                '从南边出去；权重装载后停在 PE 里不动。所有方向都固定下来，'
                '硬件连线才简单，时序才可预测。',
            ],
            'diagrams': ['pe'],
        },
        'Weight-Stationary 数据流': {
            'body': [
                '“Weight-Stationary”指权重停留在 PE 内、被反复使用。在卷积里，'
                '同一个权重会被很多输入像素使用，复用好；在矩阵乘里，每个权重'
                '会被一整行输入使用。',
                '阵列中每个 PE 存一个权重，一行激活从左往右流，部分和从上往下流。'
                '这样每个周期所有 PE 都在做乘法，硬件利用率高。',
            ],
            'diagrams': ['array'],
            'cite': 'Kung & Leiserson, Systolic Arrays (for VLSI), 1978',
        },
        '斜输入': {
            'body': [
                '如果所有行的数据同时进入阵列，第一行处理 k=0 时，第二行已经在'
                '处理 k=1，部分和就会“错位相加”。解决方法是把第 row 行的输入'
                '整体延迟 row 拍，让所有行在同一拍处理同一个 k。',
                '这就是“斜输入”（skewed input）。外部使用者不需要自己打 skew，'
                '阵列内部用移位寄存器自动完成。',
            ],
            'diagrams': ['skew'],
        },
        '输出对齐': {
            'body': [
                '由于激活在行内还要向右流，列 j 的结果天然比列 j-1 晚一拍。'
                '如果不处理，底部输出是“斜”的，控制器取数会非常麻烦。',
                '我们在阵列底部给第 col 列额外延迟 N-1-col 拍，把各列拉齐。'
                '付出几个寄存器的代价，换回“所有输出通道同一拍出现”的干净接口。',
            ],
            'diagrams': ['align'],
        },
        '时序示例': {
            'body': [
                '使用时序图最容易理解：w_load 高一个周期装载权重；之后每拍送一个'
                'a_data；最后一个输入送入后，还要等 N-1 拍让流水排空，才开始'
                '逐拍收到结果。',
                '对 N=8：装载 1 拍 + 输入 8 拍 + 排空 7 拍，第一个结果在第 15 拍'
                '（0 基的第 14 拍）出现。这些数字会在 Assignment 里让你亲手推导。',
            ],
            'diagrams': ['timing'],
        },
        '为什么叫脉动': {
            'body': [
                '“Systolic”源自心脏的收缩（systole）：数据像血液一样被周期性地'
                '推送到相邻 PE，每个 PE 只跟邻居通信。好处是连线短、时钟快、'
                '没有全局广播，坏处是数据必须按固定节奏流动，控制器要精确计算'
                '每一拍的地址。',
            ],
            'cite': 'Kung, Why Systolic Architectures?, IEEE Computer, 1982',
        },
    },
    3: {
        '阵列输出的意义': {
            'body': [
                'Ch2 的阵列输出是 C[k][col] = sum_row A[row][k] * W[row][col]。'
                '如果我们把 A 的行当作输入通道、列当作空间位置，W 的行当作输入'
                '通道、列当作输出通道，那么每个 k（每一拍）就是一个像素点上'
                '全部 N 个输出通道。',
                '这个格式非常“顺手”：卷积控制器只要逐像素产生输入向量，'
                '收集输出向量，就能完成一层卷积。',
            ],
        },
        'SRAM 组织': {
            'body': [
                'SRAM 是 NPU 的“粮仓”：输入 SRAM 存放特征图，权重 SRAM 存放模型'
                '参数，输出 SRAM 暂存结果。它们都比 Hack 的 64KB RAM 更适合阵列'
                '并行读取。',
                '容量估算例子：28x28x8 的 int8 特征图 = 6272 字节；一个小模型'
                '约 5 万参数 = 50KB 权重，足够放在片上。',
            ],
            'diagrams': ['sram'],
        },
        '控制器 FSM': {
            'body': [
                '控制器本质是一个有限状态机：IDLE 等待命令；LOAD_W 把权重搬进'
                '阵列；RUN 逐像素送数据、收结果；DRAIN 等流水排空；DONE 通知 CPU。',
                '写控制器时最难的是“地址计算”：每个像素的窗口在输入 SRAM 里'
                '对应的偏移、每个输出写回的位置，都要算对。',
            ],
            'diagrams': ['fsm'],
        },
        'im2col': {
            'body': [
                'im2col 的意思是“image to column”：把每个卷积窗口展平成一行。'
                '一个 3x3、输入通道为 C 的窗口，展平后长度是 9*C；所有窗口拼起来'
                '就是一个大矩阵，矩阵乘的结果就是卷积输出。',
                '代价是输入数据被重复复制（每个像素可能出现在多个窗口里），'
                '好处是阵列可以直接做矩阵乘，控制器逻辑简单。',
            ],
            'diagrams': ['im2col'],
            'cite': 'Sze et al., Efficient Processing of Deep Neural Networks, '
                    'Proc. IEEE, 2017',
        },
        'Line Buffer': {
            'body': [
                'Line Buffer 是另一种方案：逐行扫描图片时，只保留最近 3 行，'
                '窗口在 buffer 里滑动。这样每个像素只从外部读一次，带宽更省，'
                '但地址/时序逻辑更复杂。',
                '两种方案没有绝对优劣：im2col 简单直接，line buffer 更适合'
                '流式/低带宽设计。本章先实现一种即可。',
            ],
            'diagrams': ['linebuffer'],
        },
        'ReLU 与量化': {
            'body': [
                '阵列输出是 int32 累加和，需要先乘上 scale 反量化，再重新量化成'
                'int8 给下一层。ReLU 在量化域里只是 max(x, 0)，非常便宜。',
                '很多模型用 LeakyReLU/SiLU，硬件实现更贵（需要乘法或查表）。'
                '我们的 tiny CNN 先选 ReLU，降低 RTL 难度。',
            ],
        },
        'MaxPool': {
            'body': [
                'MaxPool 2x2 把每 2x2 窗口取最大值，宽高减半。它不做乘法，'
                '只用一个比较器和一个计数器，跟在卷积输出后面流式完成。',
                '池化让特征图变小，也减少下一层计算量；对小模型来说这是'
                '不可或缺的降采样手段。',
            ],
            'diagrams': ['pool'],
        },
        '全连接 = GEMM': {
            'body': [
                '全连接层 y = W x + b 就是矩阵乘。输入 784 维、输出 64 维，'
                '权重是 64x784 的矩阵。控制器不需要滑动窗口，直接把输入向量'
                '按 8 通道一组喂给阵列即可。',
                '这意味着同一个阵列、同一套控制逻辑，既能做卷积也能做 FC，'
                'NPU 的复用性就在这里。',
            ],
        },
        'Golden 验证': {
            'body': [
                'Golden 是“标准答案”：先用 Python 按 int8 规则逐层算出结果，'
                '导出成 hex；RTL testbench 读入同样的权重和输入，逐元素比对。',
                '关键是 Python 参考实现必须和 RTL 使用完全相同的量化规则'
                '（scale、round、clamp），否则两边永远对不上。',
            ],
        },
    },
    4: {
        '模型结构': {
            'body': [
                '我们选一个很小的 CNN：两层 3x3 卷积（8 通道、16 通道），'
                '中间夹 MaxPool，最后接 64 和 10 两个全连接。总参数约 5 万，'
                'int8 后约 50KB，NPU 片上 SRAM 放得下。',
                'MNIST 是 28x28 灰度图，单通道。两层卷积后变成 7x7x16，'
                '展平 784 维，正好接 FC。结构简单但足以演示完整链路。',
            ],
            'diagrams': ['cnn'],
            'cite': 'LeCun et al., Gradient-Based Learning Applied to Document '
                    'Recognition, Proc. IEEE, 1998',
        },
        '训练要点': {
            'body': [
                '训练用浮点做，和硬件无关。关键是固定随机种子、归一化输入、'
                '记录 float 准确率，作为量化后的对比基线。',
                '目标不是刷 SOTA：float 准确率超过 97%、int8 模拟后超过 95%，'
                '就足够说明整条链路是通的。',
            ],
        },
        '后训练量化': {
            'body': [
                '后训练量化（PTQ）不需要重新训练：拿一批校准数据跑一遍，统计'
                '每层激活的 min/max，算出 scale；权重直接用自身的 min/max。',
                '对称量化公式是 q = round(clamp(x / scale, -128, 127))，'
                'scale = max(|x|) / 127。量化误差会累积，所以逐层用 int8 模拟'
                '验证很重要。',
            ],
            'diagrams': ['quant'],
            'cite': 'Jacob et al., Quantization and Training of Neural Networks '
                    'for Efficient Integer-Arithmetic-Only Inference, CVPR 2018',
        },
        'BN 折叠': {
            'body': [
                'BatchNorm 在训练时依赖 batch 统计量，但推理时 mean/var 是常量，'
                '可以“折叠”进前一层的卷积权重：w_fold = w*gamma/sqrt(var+eps)，'
                'bias 也一起合并。',
                '折叠后 RTL 不需要实现 BN 单元，省掉一个模块，也少一层量化误差。',
            ],
        },
        '导出格式': {
            'body': [
                '导出的内容有四种：权重（weights.hex）、一张测试图片'
                '（image.hex）、每层 golden 输出（golden.hex）、每层的 scale 和'
                '布局信息（scales.json）。',
                '布局必须和 Ch3 的 SRAM 定义一致：行主序、int8 补码。'
                '这是软件和硬件之间最容易出错的地方。',
            ],
            'diagrams': ['export'],
        },
        'Python int8 模拟器': {
            'body': [
                '“Python int8 模拟器”就是在 PyTorch 里用整数运算重新实现前向'
                '传播：每个卷积/FC 输出先反量化再量化回 int8，激活也一样。',
                '它跑出来的结果就是 RTL 的 golden。模拟器正确，RTL 才有对照；'
                '模拟器错了，RTL 再对也是错上加错。',
            ],
        },
        '常见坑': {
            'body': [
                '最常见的是 round 规则不一致：Python 的 round() 是银行家舍入，'
                '硬件常用四舍五入，必须统一成同一种。',
                '其次是 scale 精度：用 float 计算 scale 没问题，但导出后如果'
                '被截断成 int16，误差会被放大。还有 ReLU 之后 tensor 的 min 是 0，'
                '不能用负值范围。',
            ],
        },
    },
    5: {
        'Hack + NPU 系统': {
            'body': [
                '最后一步是把 NPU 挂进 `n2t_computer_posedge`：Memory 在地址译码时增加'
                '0x7000-0x7FFF 段，命中该段就把读写转给 NPU。CPU 跑一条普通'
                '汇编指令就能触发 NPU。',
                '对 CPU 而言 NPU 只是“一块特殊的内存”；对 NPU 而言 CPU 只是'
                '“一个会读写寄存器的控制器”。这就是 MMIO 的对称性。',
            ],
            'diagrams': ['soc'],
        },
        'MMIO 地址分配': {
            'body': [
                'Hack 原始地址空间：0x0000-0x3FFF 是 RAM，0x4000-0x5FFF 是 Screen，'
                '0x6000 是 Keyboard。0x7000 以上未使用，所以 NPU 占用这一段不会'
                '破坏原有程序。',
                '寄存器表建议：0x7000 CMD、0x7001 STATUS、0x7002 ADDR_SRC、'
                '0x7003 ADDR_DST、0x7004 LENGTH。具体位宽在 Ch1 Assignment 里设计。',
            ],
            'diagrams': ['addr_map'],
        },
        '命令协议': {
            'body': [
                '握手协议要简单可靠：CPU 先写参数，再写 CMD=START；NPU 收到后'
                '把 BUSY 置 1，开始执行；完成后 BUSY 清零、DONE 置 1；CPU 轮询'
                '到 DONE 后读结果，最后写 CMD=CLR 清状态。',
                '这个协议不需要中断，也不需要新的 Hack 指令，完全用现有汇编'
                '读写内存实现。',
            ],
            'diagrams': ['handshake'],
        },
        'Hack 驱动': {
            'body': [
                'Hack 汇编驱动核心就几行：把地址常数加载到 A，用 `M=D` 写寄存器，'
                '用 `D=M` 读寄存器，用跳转指令循环轮询。',
                '驱动里没有乘法，也没有矩阵运算——那些都在 NPU 里。驱动只负责'
                '“把任务描述清楚”和“等结果”。',
            ],
            'diagrams': ['driver'],
        },
        '轮询 vs 中断': {
            'body': [
                '轮询（polling）就是 CPU 反复读 STATUS，直到完成位出现。'
                '实现简单，但 CPU 在等待期间不能干别的。',
                '中断（interrupt）需要硬件在完成时打断 CPU，Hack 指令集没有'
                '中断机制，所以本章用轮询。真实系统中小任务轮询也完全够用。',
            ],
        },
        '集成测试': {
            'body': [
                '集成测试的输入是 Ch4 导出的一张图片和权重文件；仿真启动时通过'
                '`$readmemh` 预置到 SRAM/RAM。CPU 跑驱动，NPU 算完，测试台读取'
                '最终结果并检查 argmax。',
                '验收标准两条：原有 `make test` 必须全绿（不能破坏 Hack 语义），'
                '新增端到端测试必须 PASS。',
            ],
            'cite': 'Jouppi et al., In-Datacenter Performance Analysis of a Tensor '
                    'Processing Unit, ISCA 2017',
        },
        '扩展方向': {
            'body': [
                'MNIST 之后，同一个框架可以换数据集、加深网络，也可以评估 tiny '
                'YOLO：卷积和 FC 直接复用，需要新增的是 upsample、concat、'
                '检测头和后处理 NMS。',
                'NMS 这类控制密集的后处理可以留在 CPU 或 Python，NPU 只做'
                '最重的张量运算，这是真实 SoC 的常见分工。',
            ],
            'cite': 'Redmon & Farhadi, YOLOv3: An Incremental Improvement, arXiv 2018',
        },
    },
}

# ---------------------------------------------------------------------------
# “高中生版”深挖补充：类比优先，把每个概念再讲透一层
# ---------------------------------------------------------------------------
DEEPER_NOTES = {
    1: {
        '为什么 CPU 跑不动 CNN': {
            'body': [
                '打个比方：CPU 像一个“只会按菜单一步步做菜的厨师”，'
                '每做一次乘法都要先翻菜单（取指令）、再看菜单（译码）、'
                '再做菜（执行）。如果一道菜要加 10 万个调料，他就得翻 10 万次菜单。',
                'NPU 的做法是：把 64 个“小厨师”排成一排，每人同时做一个乘法，'
                '菜单只翻一次，后面的工作全部流水线完成。这就是“专用硬件加速”'
                '最朴素的理解。',
            ],
            'diagrams': ['mul'],
        },
        '系统分层': {
            'body': [
                '可以把系统想成一个办公室：CPU 是经理，内存是文件柜，'
                'NPU 是专门负责算账的会计。经理不亲自算账，他写一张纸条'
                '（命令），放到会计桌上的收件箱（寄存器），会计算完把结果'
                '放进发件箱，经理隔一会儿来看一眼（轮询）。',
                'MMIO 就是“给收件箱和发件箱也编了门牌号”，经理用送文件的'
                '同一套方式（读写内存的指令）就能递纸条。',
            ],
            'diagrams': ['bus'],
        },
        'NPU 内部结构': {
            'body': [
                'NPU 内部像一个小工厂：寄存器是门口的公告栏（写命令、看状态）；'
                'SRAM 是原料仓库（权重、图片、中间结果）；脉动阵列是车间'
                '（一排排乘法器）；控制器是车间主任（决定什么时候把什么原料'
                '送进车间）。',
                '不要以为 NPU 很神秘：它和你家里的厨房一样，只是把“做乘法”'
                '这件事做得特别快、特别专一。',
            ],
            'diagrams': ['memory'],
        },
        'MMIO 协议': {
            'body': [
                '想象你给一台自动售货机下指令：先按“可乐”（写参数），再按'
                '“确认”（写 CMD=START），机器开始出货（BUSY=1），出货完成'
                '亮灯（DONE=1），你取货（读结果）。',
                'MMIO 协议就是把这套“按钮”都变成地址。CPU 不需要学新指令，'
                '只需要知道：0x7000 是“确认键”，0x7001 是“状态灯”。',
            ],
        },
        '为什么是 int8': {
            'body': [
                '浮点数像一把非常精细的尺子，能量到小数点后很多位，但尺子很贵；'
                'int8 像一把只有 256 个刻度的尺子，便宜、轻便，大多数情况下'
                '够用。',
                '量化就是“换尺子”：先量出数据最大有多宽（min/max），算出每格'
                '代表多少（scale），然后把每个数四舍五入到最近的格子上。'
                '误差肯定有，但模型通常能接受。',
            ],
        },
        'GEMM 是核心算子': {
            'body': [
                '矩阵乘法像乐高：很多复杂的东西（卷积、全连接）最后都能拆成'
                '同一块积木——乘加。只要把这块积木做得飞快，整座大楼就建得快。',
                '所以 NPU 设计的第一问题不是“支持什么网络”，而是“矩阵乘怎么算'
                '最快”。脉动阵列就是答案之一。',
            ],
        },
        '数据流总览': {
            'body': [
                '整条数据流像一条工厂流水线：图片从仓库（RAM）搬到原料间'
                '（输入 SRAM），模型参数搬进模具柜（权重 SRAM），车间'
                '（脉动阵列）逐像素加工，成品经过质检（ReLU/池化）后放进'
                '成品库（输出 SRAM），最后经理（CPU）把成品拿回办公室（RAM）。',
                '后面每一章都是这条流水线的一个工位：Ch2 做车间，Ch3 做传送带'
                '和质检，Ch4 准备模具，Ch5 让经理学会下单。',
            ],
        },
    },
    2: {
        'PE 接口': {
            'body': [
                '把 PE 想成一个收银台：a 是顾客（数据）从左边进来，算完从右边'
                '出去；w 是这台收银台的单价表，装好后一直摆在台上；'
                'psum 是“到目前为止应该收多少钱”，从楼上递下来，加上这一笔'
                '再递给楼下。',
                '每个 PE 只做一件事：金额 = 楼下传来的金额 + 顾客 x 单价。'
                '非常简单，但成千上万个 PE 同时做，就非常快。',
            ],
        },
        'Weight-Stationary 数据流': {
            'body': [
                '“Weight-Stationary”可以翻译成“权重坐镇”。权重像印章：'
                '印章做好后放在桌上，很多张纸（输入）轮流盖，不用每次重新刻章。',
                '阵列里每个 PE 存一个印章（权重），输入像纸一样从左边流进来，'
                '部分和像流水一样从上往下汇合。因为权重不用频繁搬动，'
                '省下的搬运时间就是加速。',
            ],
        },
        '斜输入': {
            'body': [
                '如果三列队伍同时出发，第 1 列已经走了 1 步，第 3 列才刚起步，'
                '到终点时大家踩的点就错开了。斜输入就是让第 row 列晚 row 步'
                '出发，保证所有列在同一时刻踩到同一个节拍上。',
                '在硬件里，“晚几步出发”就是给那一行加几个延迟寄存器。'
                '这个设计让“部分和”能一层一层正确累加。',
            ],
        },
        '输出对齐': {
            'body': [
                '因为数据要往右流过每一列，最右边的列天然最晚算出结果，'
                '就像三条生产线长短不同，出货时间不一样。',
                '输出对齐就是给短的生产线加一段“传送带延迟”，让三条线的'
                '成品同时到达包装台。代价只是几个寄存器，收益是控制器'
                '可以一次性拿到一整排结果。',
            ],
        },
        '时序示例': {
            'body': [
                '把阵列想象成一条地铁：第一节车厢（第 0 行）先出发，'
                '第二节晚一站（延迟 1 拍），第三节晚两站……每一站停靠时'
                '所有车厢正好同时处理同一个 k。',
                '所以“输入 8 拍 + 排空 7 拍”不是随便定的，而是由车厢数'
                '（N）决定的。Assignment 里会让你自己推这个公式。',
            ],
        },
        '为什么叫脉动': {
            'body': [
                '心脏把血液一下一下泵出去，血液在血管里按固定节拍流动。'
                '脉动阵列也一样：数据被时钟一拍一拍“泵”进 PE，每个 PE 只和'
                '左右上下的邻居交换数据，没有全局广播。',
                '好处是每根连线都很短，芯片可以跑很高频率；坏处是数据必须'
                '严格按节拍来，控制器要算好每一拍谁在哪儿。',
            ],
        },
    },
    3: {
        '阵列输出的意义': {
            'body': [
                '回想矩阵乘法：C 的每一格 = A 的一行点乘 B 的一列。'
                '我们让 A 的“行”是输入通道，B 的“列”是输出通道，'
                '那么 C 的一列就是“一个像素的所有输出通道”。',
                '所以阵列每拍吐出一个向量，正好是卷积输出里一个像素点的'
                '完整结果。控制器不需要重新拼装，直接写进输出 SRAM 就行。',
            ],
            'diagrams': ['matrix'],
        },
        'SRAM 组织': {
            'body': [
                '仓库要分区：原料（输入特征图）放 A 区，模具（权重）放 B 区，'
                '成品（输出特征图）放 C 区。每个区用地址编号，控制器按编号'
                '取货。',
                '容量估算很简单：一个 int8 数占 1 字节，所以 28x28x8 的特征图'
                '就是 28*28*8 = 6272 字节。先学会算这个，后面设计 SRAM 才有数。',
            ],
        },
        '控制器 FSM': {
            'body': [
                '状态机就像红绿灯：红灯等（IDLE），绿灯放行（RUN），'
                '黄灯清空路口（DRAIN）。控制器只做三件事：等命令、'
                '按顺序送数据、收结果。',
                '最容易被忽略的是 DRAIN：最后一拍输入后，流水线里还有数据'
                '没走完，必须等它排空，否则结果会丢。',
            ],
        },
        'im2col': {
            'body': [
                'im2col 像把一张照片剪成很多小卡片：每个 3x3 窗口剪成一张'
                '长条，所有长条排成一摞，就变成矩阵。矩阵乘完再把结果'
                '按位置贴回去。',
                '代价是同一块像素会出现在多张卡片里（重复存储），'
                '好处是计算部分变成了纯粹的矩阵乘，控制器非常好写。',
            ],
        },
        'Line Buffer': {
            'body': [
                'Line Buffer 的思路是“边看边扔”：读图片时只保留最近 3 行，'
                '窗口在内存里滑动，滑过去不再需要的行就扔掉。',
                '它比 im2col 省内存和带宽，但地址计算更绕。'
                '两种方案都可以，第一次做建议先选 im2col，跑通后再优化。',
            ],
        },
        'ReLU 与量化': {
            'body': [
                'ReLU 的中文意思就是“负数清零”：z 小于 0 就输出 0，'
                '否则原样输出。它像把成绩单里的负分全部改成 0。',
                '量化域里做 ReLU 更简单：int8 的负数直接变 0，不需要查表、'
                '不需要浮点。这也是为什么小模型优先选 ReLU。',
            ],
        },
        'MaxPool': {
            'body': [
                'MaxPool 2x2 把图片分成很多 2x2 的小方块，每个方块只留最大值。'
                '相当于把 4 张图缩成 1 张，信息量减少但保留最明显的特征。',
                '实现上只需要比较器：两个数比大小，大的留下。它不占用'
                '乘法器，是 NPU 里最便宜的层之一。',
            ],
        },
        '全连接 = GEMM': {
            'body': [
                '全连接层就像点名册：784 个学生（输入特征）每人乘一个权重，'
                '加总后得到 64 个“班级总分”（输出特征）。所有学生 x 所有权重'
                '就是一张大矩阵乘法表。',
                'NPU 不需要为 FC 另造硬件：卷积和 FC 都喂给同一个阵列，'
                '只是控制器的“送数据方式”不同。',
            ],
            'diagrams': ['neuron'],
        },
        'Golden 验证': {
            'body': [
                'Golden 就是“标准答案”。就像考试前老师先做一遍卷子，'
                '把答案锁在保险柜里，学生（RTL）做完后拿出来对。',
                '关键是老师（Python）和学生（RTL）必须用同一套规则：'
                '同样的取整、同样的截断、同样的数据顺序。规则不一致，'
                '两个人都会觉得自己是对的。',
            ],
        },
    },
    4: {
        '模型结构': {
            'body': [
                '搭神经网络像搭乐高：先用卷积“看”局部特征，用池化“缩小”'
                '图片，用全连接“总结”成 10 个类别的分数。',
                '我们的模型很小：两层卷积 + 两个全连接，约 5 万参数。'
                '小不是缺点——它刚好能塞进 NPU 的片上 SRAM，也足够演示'
                '“训练 -> 量化 -> 硬件推理”的完整流程。',
            ],
        },
        '训练要点': {
            'body': [
                '训练就像考试前的复习：给模型看很多带答案的题（MNIST 图片'
                '和标签），让它不断调整权重，把答错的题改正。',
                '固定随机种子是为了“每次复习的起点一样”，这样实验结果'
                '可复现。float 准确率是量化前的成绩，int8 准确率是量化后的'
                '成绩，两份都要记录。',
            ],
        },
        '后训练量化': {
            'body': [
                '量化像把一张精细的照片压成 256 级灰度：先看整张照片最亮'
                '和最暗是多少（min/max），把亮度范围分成 256 格，'
                '每个像素落到最近的一格。',
                '公式 q = round(clamp(x/scale, -128, 127)) 里的 clamp 是“夹住”：'
                '超出范围的数强行压到边界，round 是四舍五入。',
            ],
        },
        'BN 折叠': {
            'body': [
                'BatchNorm 像“先调音量再录音”：训练时它动态调，推理时'
                '音量固定了。固定之后，调音量可以和前一步录音合并成一步。',
                '硬件里少一个模块就少一分出错可能，所以推理时把 BN 的'
                '缩放和偏移直接写进卷积权重，RTL 完全不用知道 BN 存在。',
            ],
        },
        '导出格式': {
            'body': [
                '导出文件就像快递单：weights.hex 是货物（权重），image.hex 是'
                '发货的图片，golden.hex 是签收标准（正确输出），scales.json 是'
                '尺寸说明（每层 scale）。',
                '硬件和软件必须对同一张“快递单”有完全相同的理解：先放哪个'
                '数、每个数多宽、按什么顺序。这就是布局格式的重要性。',
            ],
        },
        'Python int8 模拟器': {
            'body': [
                '在真正上硬件之前，先在 Python 里“模拟考”：用 int8 规则'
                '把模型完整跑一遍，得到标准答案。',
                '这一步能帮你提前发现量化问题，比如某层误差特别大、'
                'scale 算错、布局不对。Python 模拟器对了，RTL 调试才有'
                '可靠的对照物。',
            ],
        },
        '常见坑': {
            'body': [
                'Python 的 round() 是“银行家舍入”（0.5 可能舍成 0），'
                '硬件常用的四舍五入是“0.5 进 1”，两边必须统一。',
                '另一个坑是 ReLU 后的激活全是非负数，min 不再是负数，'
                '如果还用训练前的 min/max 就会浪费一半量化范围。',
            ],
        },
    },
    5: {
        'Hack + NPU 系统': {
            'body': [
                '把 NPU 挂进 Hack 就像给自行车加了一个电机：骑车的人'
                '（CPU）还是控制方向，但爬坡（矩阵计算）交给电机（NPU）。',
                '改造点只有一个：Memory 在地址译码时多认一段地址，'
                '这段地址的读写全部转给 NPU。对 CPU 来说，'
                '“让 NPU 干活”和“写内存”是同一件事。',
            ],
        },
        'MMIO 地址分配': {
            'body': [
                '地址就像小区门牌：0x0000-0x3FFF 是居民楼（RAM），'
                '0x4000-0x5FFF 是商场屏幕（Screen），0x6000 是门卫室'
                '（Keyboard），0x7000 以上是新建的 NPU 厂房。',
                '只要新地址不占老门牌，原来的居民（旧程序）就完全不受影响。'
                '这也是为什么把 NPU 放在 0x7000+。',
            ],
        },
        '命令协议': {
            'body': [
                '协议就是“先做什么、再做什么”的约定。我们的约定是：'
                '先填地址参数，再按“开始”按钮（写 CMD），NPU 亮“工作中”'
                '灯（BUSY），算完亮“完成”灯（DONE），CPU 看到灯后取结果。',
                '协议越简单越不容易出错。真实芯片里的握手协议通常也是'
                '这个模式的加强版。',
            ],
        },
        'Hack 驱动': {
            'body': [
                '驱动就是写给 CPU 的“操作手册”：把图片地址写到 0x7002，'
                '把结果地址写到 0x7003，向 0x7000 写 1，然后反复读 0x7001'
                '直到完成位出现。',
                'Hack 没有乘法指令，但没关系——驱动里不需要乘法。'
                '它只是“传话的人”，真正的数学在 NPU 里。',
            ],
        },
        '轮询 vs 中断': {
            'body': [
                '轮询像你在洗衣机前一直盯着“剩余时间”，直到显示 0。'
                '简单，但期间你什么别的事都干不了。',
                '中断像洗衣机洗完会“叮”一声叫你，你可以先去看书。'
                'Hack 没有“叮”这个硬件机制，所以我们用轮询。',
            ],
        },
        '集成测试': {
            'body': [
                '集成测试就是“全流程彩排”：图片、权重、程序全部就位，'
                'CPU 按剧本（驱动）走，NPU 按剧本算，最后检查输出类别'
                '是不是标准答案（golden）。',
                '同时还要跑一遍旧考试（make test），确保加了 NPU 之后，'
                '原来的 Hack 电脑没有被改坏。',
            ],
        },
        '扩展方向': {
            'body': [
                'MNIST 是“小样”，证明整条流水线能跑通。换成 tiny YOLO 时，'
                '卷积、FC、池化都能复用，新增的是上采样、拼接、检测头和'
                'NMS。',
                '真实系统里 NMS 这类“判断多、计算少”的活通常留给 CPU，'
                'NPU 只做“计算多、判断少”的张量运算。',
            ],
        },
    },
}

LECTURE_REFS = {
    1: [
        'Kung, H.T., "Why Systolic Architectures?", IEEE Computer, 1982.',
        'Jouppi et al., "In-Datacenter Performance Analysis of a Tensor Processing Unit", ISCA 2017.',
        'Sze et al., "Efficient Processing of Deep Neural Networks: A Tutorial and Survey", Proceedings of the IEEE, 2017.',
        'Patterson & Hennessy, "Computer Organization and Design"（MMIO / I/O 章节）.',
    ],
    2: [
        'Kung & Leiserson, "Systolic Arrays (for VLSI)", 1978.',
        'Kung, H.T., "Why Systolic Architectures?", IEEE Computer, 1982.',
        'Jouppi et al., "In-Datacenter Performance Analysis of a Tensor Processing Unit", ISCA 2017.',
        'Sze et al., "Efficient Processing of Deep Neural Networks: A Tutorial and Survey", Proceedings of the IEEE, 2017.',
    ],
    3: [
        'Sze et al., "Efficient Processing of Deep Neural Networks: A Tutorial and Survey", Proceedings of the IEEE, 2017.',
        'Chen et al., "Eyeriss: An Energy-Efficient Reconfigurable Accelerator for Deep Convolutional Neural Networks", ISSCC 2016.',
        'Han et al., "EIE: Efficient Inference Engine on Compressed Deep Neural Network", ISCA 2016.',
        'Han et al., "Deep Compression: Compressing Deep Neural Networks with Pruning, Trained Quantization and Huffman Coding", ICLR 2016.',
    ],
    4: [
        'Jacob et al., "Quantization and Training of Neural Networks for Efficient Integer-Arithmetic-Only Inference", CVPR 2018.',
        'LeCun et al., "Gradient-Based Learning Applied to Document Recognition", Proceedings of the IEEE, 1998（MNIST）.',
        'Han et al., "Deep Compression", ICLR 2016.',
        'Sze et al., "Efficient Processing of Deep Neural Networks", Proceedings of the IEEE, 2017.',
    ],
    5: [
        'Patterson & Hennessy, "Computer Organization and Design"（memory-mapped I/O）.',
        'Jouppi et al., "In-Datacenter Performance Analysis of a Tensor Processing Unit", ISCA 2017.',
        'Redmon et al., "You Only Look Once: Unified, Real-Time Object Detection", CVPR 2016.',
        'Redmon & Farhadi, "YOLOv3: An Incremental Improvement", arXiv 1804.02767, 2018.',
    ],
}


def main():
    register_font()
    st = build_styles()
    wanted = set(sys.argv[1:]) or {str(c['num']) for c in CHAPTERS}
    for ch in CHAPTERS:
        if str(ch['num']) not in wanted:
            continue
        notes = LECTURE_NOTES.get(ch['num'], {})
        for slide in ch['lecture']['slides']:
            extra = notes.get(slide['title'], {})
            if extra.get('body'):
                slide.setdefault('body', []).extend(extra['body'])
            if extra.get('diagrams'):
                slide.setdefault('diagrams', []).extend(extra['diagrams'])
            if extra.get('cite'):
                slide['cite'] = extra['cite']
            extra2 = DEEPER_NOTES.get(ch['num'], {}).get(slide['title'], {})
            if extra2.get('body'):
                slide.setdefault('body', []).extend(extra2['body'])
            if extra2.get('diagrams'):
                slide.setdefault('diagrams', []).extend(extra2['diagrams'])
        ch['lecture']['refs'] = LECTURE_REFS.get(ch['num'], [])
        render_project(ch['num'], ch, st)
        render_lecture(ch['num'], ch, st)
        render_assignment(ch['num'], ch, st)
    print('done: %d chapter(s), 3 PDFs each' % len(wanted))


if __name__ == '__main__':
    main()
