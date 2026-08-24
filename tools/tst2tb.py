#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
tst2tb.py — 把 nand2tetris 官方 .tst/.cmp 测试脚本翻译成 Verilog testbench。

用法：
    python3 tools/tst2tb.py [chip ...]     # 不传参数则生成全部

生成的 testbench 与官方测试逐行对应：tick/tock/eval/output 语义保持一致，
期望值直接从 .cmp 表格嵌入；跑 vvp 时逐行比对并统计 PASS/FAIL。
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

# ---------------------------------------------------------------------------
# 芯片配置：端口 (name, width, dir)，dir 为 'clk'/'in'/'out'
# 端口名与 solution/ 下的 Verilog 模块端口一一对应；probes 为层级探针
# ---------------------------------------------------------------------------
def P(*ports):
    return list(ports)


CHIPS = {
    # ---------------- Project 1 ----------------
    'Not': dict(tst='ref/01/Not.tst', cmp='ref/01/Not.cmp', inst='dut',
                ports=P(('in', 1, 'in'), ('out', 1, 'out'))),
    'And': dict(tst='ref/01/And.tst', cmp='ref/01/And.cmp', inst='dut',
                ports=P(('a', 1, 'in'), ('b', 1, 'in'), ('out', 1, 'out'))),
    'Or': dict(tst='ref/01/Or.tst', cmp='ref/01/Or.cmp', inst='dut',
               ports=P(('a', 1, 'in'), ('b', 1, 'in'), ('out', 1, 'out'))),
    'Xor': dict(tst='ref/01/Xor.tst', cmp='ref/01/Xor.cmp', inst='dut',
                ports=P(('a', 1, 'in'), ('b', 1, 'in'), ('out', 1, 'out'))),
    'Mux': dict(tst='ref/01/Mux.tst', cmp='ref/01/Mux.cmp', inst='dut',
                ports=P(('a', 1, 'in'), ('b', 1, 'in'), ('sel', 1, 'in'), ('out', 1, 'out'))),
    'DMux': dict(tst='ref/01/DMux.tst', cmp='ref/01/DMux.cmp', inst='dut',
                 ports=P(('in', 1, 'in'), ('sel', 1, 'in'), ('a', 1, 'out'), ('b', 1, 'out'))),
    'Not16': dict(tst='ref/01/Not16.tst', cmp='ref/01/Not16.cmp', inst='dut',
                  ports=P(('in', 16, 'in'), ('out', 16, 'out'))),
    'And16': dict(tst='ref/01/And16.tst', cmp='ref/01/And16.cmp', inst='dut',
                  ports=P(('a', 16, 'in'), ('b', 16, 'in'), ('out', 16, 'out'))),
    'Or16': dict(tst='ref/01/Or16.tst', cmp='ref/01/Or16.cmp', inst='dut',
                 ports=P(('a', 16, 'in'), ('b', 16, 'in'), ('out', 16, 'out'))),
    'Mux16': dict(tst='ref/01/Mux16.tst', cmp='ref/01/Mux16.cmp', inst='dut',
                  ports=P(('a', 16, 'in'), ('b', 16, 'in'), ('sel', 1, 'in'), ('out', 16, 'out'))),
    'Or8Way': dict(tst='ref/01/Or8Way.tst', cmp='ref/01/Or8Way.cmp', inst='dut',
                   ports=P(('in', 8, 'in'), ('out', 1, 'out'))),
    'Mux4Way16': dict(tst='ref/01/Mux4Way16.tst', cmp='ref/01/Mux4Way16.cmp', inst='dut',
                      ports=P(('a', 16, 'in'), ('b', 16, 'in'), ('c', 16, 'in'), ('d', 16, 'in'),
                              ('sel', 2, 'in'), ('out', 16, 'out'))),
    'Mux8Way16': dict(tst='ref/01/Mux8Way16.tst', cmp='ref/01/Mux8Way16.cmp', inst='dut',
                      ports=P(('a', 16, 'in'), ('b', 16, 'in'), ('c', 16, 'in'), ('d', 16, 'in'),
                              ('e', 16, 'in'), ('f', 16, 'in'), ('g', 16, 'in'), ('h', 16, 'in'),
                              ('sel', 3, 'in'), ('out', 16, 'out'))),
    'DMux4Way': dict(tst='ref/01/DMux4Way.tst', cmp='ref/01/DMux4Way.cmp', inst='dut',
                     ports=P(('in', 1, 'in'), ('sel', 2, 'in'),
                             ('a', 1, 'out'), ('b', 1, 'out'), ('c', 1, 'out'), ('d', 1, 'out'))),
    'DMux8Way': dict(tst='ref/01/DMux8Way.tst', cmp='ref/01/DMux8Way.cmp', inst='dut',
                     ports=P(('in', 1, 'in'), ('sel', 3, 'in'),
                             ('a', 1, 'out'), ('b', 1, 'out'), ('c', 1, 'out'), ('d', 1, 'out'),
                             ('e', 1, 'out'), ('f', 1, 'out'), ('g', 1, 'out'), ('h', 1, 'out'))),
    # ---------------- Project 2 ----------------
    'HalfAdder': dict(tst='ref/02/HalfAdder.tst', cmp='ref/02/HalfAdder.cmp', inst='dut',
                      ports=P(('a', 1, 'in'), ('b', 1, 'in'), ('sum', 1, 'out'), ('carry', 1, 'out'))),
    'FullAdder': dict(tst='ref/02/FullAdder.tst', cmp='ref/02/FullAdder.cmp', inst='dut',
                      ports=P(('a', 1, 'in'), ('b', 1, 'in'), ('c', 1, 'in'),
                              ('sum', 1, 'out'), ('carry', 1, 'out'))),
    'Add16': dict(tst='ref/02/Add16.tst', cmp='ref/02/Add16.cmp', inst='dut',
                  ports=P(('a', 16, 'in'), ('b', 16, 'in'), ('out', 16, 'out'))),
    'Inc16': dict(tst='ref/02/Inc16.tst', cmp='ref/02/Inc16.cmp', inst='dut',
                  ports=P(('in', 16, 'in'), ('out', 16, 'out'))),
    'ALU': dict(tst='ref/02/ALU.tst', cmp='ref/02/ALU.cmp', inst='dut',
                ports=P(('x', 16, 'in'), ('y', 16, 'in'),
                        ('zx', 1, 'in'), ('nx', 1, 'in'), ('zy', 1, 'in'), ('ny', 1, 'in'),
                        ('f', 1, 'in'), ('no', 1, 'in'),
                        ('out', 16, 'out'), ('zr', 1, 'out'), ('ng', 1, 'out'))),
    # ---------------- Project 3 ----------------
    'Bit': dict(tst='ref/03/a/Bit.tst', cmp='ref/03/a/Bit.cmp', inst='dut',
                ports=P(('clk', 1, 'clk'), ('in', 1, 'in'), ('load', 1, 'in'), ('out', 1, 'out'))),
    'Register': dict(tst='ref/03/a/Register.tst', cmp='ref/03/a/Register.cmp', inst='dut',
                     ports=P(('clk', 1, 'clk'), ('in', 16, 'in'), ('load', 1, 'in'), ('out', 16, 'out'))),
    'RAM8': dict(tst='ref/03/a/RAM8.tst', cmp='ref/03/a/RAM8.cmp', inst='dut',
                 ports=P(('clk', 1, 'clk'), ('in', 16, 'in'), ('load', 1, 'in'),
                         ('address', 3, 'in'), ('out', 16, 'out'))),
    'RAM64': dict(tst='ref/03/a/RAM64.tst', cmp='ref/03/a/RAM64.cmp', inst='dut',
                  ports=P(('clk', 1, 'clk'), ('in', 16, 'in'), ('load', 1, 'in'),
                          ('address', 6, 'in'), ('out', 16, 'out'))),
    'RAM512': dict(tst='ref/03/b/RAM512.tst', cmp='ref/03/b/RAM512.cmp', inst='dut',
                   ports=P(('clk', 1, 'clk'), ('in', 16, 'in'), ('load', 1, 'in'),
                           ('address', 9, 'in'), ('out', 16, 'out'))),
    'RAM4K': dict(tst='ref/03/b/RAM4K.tst', cmp='ref/03/b/RAM4K.cmp', inst='dut',
                  ports=P(('clk', 1, 'clk'), ('in', 16, 'in'), ('load', 1, 'in'),
                          ('address', 12, 'in'), ('out', 16, 'out'))),
    'RAM16K': dict(tst='ref/03/b/RAM16K.tst', cmp='ref/03/b/RAM16K.cmp', inst='dut',
                   ports=P(('clk', 1, 'clk'), ('in', 16, 'in'), ('load', 1, 'in'),
                           ('address', 15, 'in'),
                           ('dbg_we', 1, 'in'), ('dbg_addr', 14, 'in'), ('dbg_wdata', 16, 'in'),
                           ('out', 16, 'out'))),
    'PC': dict(tst='ref/03/a/PC.tst', cmp='ref/03/a/PC.cmp', inst='dut',
               ports=P(('clk', 1, 'clk'), ('in', 16, 'in'), ('load', 1, 'in'),
                       ('inc', 1, 'in'), ('reset', 1, 'in'), ('out', 16, 'out'))),
    # ---------------- Project 5 ----------------
    'CPU': dict(tst='ref/05/CPU.tst', cmp='ref/05/CPU.cmp', inst='cpu',
                ports=P(('clk', 1, 'clk'), ('inM', 16, 'in'), ('instruction', 16, 'in'),
                        ('reset', 1, 'in'),
                        ('outM', 16, 'out'), ('writeM', 1, 'out'),
                        ('addressM', 15, 'out'), ('pc', 15, 'out')),
                probes={'DRegister[]': ('cpu.d_reg', 16)}),
    'ComputerAdd': dict(tst='ref/05/ComputerAdd.tst', cmp='ref/05/ComputerAdd.cmp', inst='u_comp',
                        ports=P(('clk', 1, 'clk'), ('reset', 1, 'in'),
                                ('outM', 16, 'out'), ('writeM', 1, 'out'),
                                ('addressM', 15, 'out'), ('pc', 15, 'out'),
                                ('dbg_we', 1, 'in'), ('dbg_addr', 14, 'in'), ('dbg_wdata', 16, 'in')),
                        probes={'ARegister[]': ('u_comp.u_cpu.a_reg', 16),
                                'ARegister[0]': ('u_comp.u_cpu.a_reg', 16),
                                'DRegister[]': ('u_comp.u_cpu.d_reg', 16),
                                'DRegister[0]': ('u_comp.u_cpu.d_reg', 16),
                                'PC[]': ('u_comp.u_cpu.pc_reg', 15),
                                'RAM16K[0]': ('u_comp.u_mem.u_ram.mem[0]', 16),
                                'RAM16K[1]': ('u_comp.u_mem.u_ram.mem[1]', 16),
                                'RAM16K[2]': ('u_comp.u_mem.u_ram.mem[2]', 16)}),
    'ComputerMax': dict(tst='ref/05/ComputerMax.tst', cmp='ref/05/ComputerMax.cmp', inst='u_comp',
                        ports=P(('clk', 1, 'clk'), ('reset', 1, 'in'),
                                ('outM', 16, 'out'), ('writeM', 1, 'out'),
                                ('addressM', 15, 'out'), ('pc', 15, 'out'),
                                ('dbg_we', 1, 'in'), ('dbg_addr', 14, 'in'), ('dbg_wdata', 16, 'in')),
                        probes={'ARegister[]': ('u_comp.u_cpu.a_reg', 16),
                                'DRegister[]': ('u_comp.u_cpu.d_reg', 16),
                                'PC[]': ('u_comp.u_cpu.pc_reg', 15),
                                'RAM16K[0]': ('u_comp.u_mem.u_ram.mem[0]', 16),
                                'RAM16K[1]': ('u_comp.u_mem.u_ram.mem[1]', 16),
                                'RAM16K[2]': ('u_comp.u_mem.u_ram.mem[2]', 16)}),
    'ComputerRect': dict(tst='ref/05/ComputerRect.tst', cmp='ref/05/ComputerRect.cmp', inst='u_comp',
                         ports=P(('clk', 1, 'clk'), ('reset', 1, 'in'),
                                 ('outM', 16, 'out'), ('writeM', 1, 'out'),
                                 ('addressM', 15, 'out'), ('pc', 15, 'out'),
                                 ('dbg_we', 1, 'in'), ('dbg_addr', 14, 'in'), ('dbg_wdata', 16, 'in')),
                         probes={'ARegister[]': ('u_comp.u_cpu.a_reg', 16),
                                 'DRegister[]': ('u_comp.u_cpu.d_reg', 16),
                                 'PC[]': ('u_comp.u_cpu.pc_reg', 15),
                                 'RAM16K[0]': ('u_comp.u_mem.u_ram.mem[0]', 16),
                                 'RAM16K[1]': ('u_comp.u_mem.u_ram.mem[1]', 16),
                                 'RAM16K[2]': ('u_comp.u_mem.u_ram.mem[2]', 16)}),
    # ---------------- Project 6（自定义 NPU 扩展）----------------
    # manual_tb=True 表示 testbench 是手工维护的（tb/06/*_tb.v），
    # tools/tst2tb.py 与 server/gen_wave.py 遇到时不会用 .tst/.cmp 覆盖。
    'PE': dict(manual_tb=True, inst='dut',
               ports=P(('clk', 1, 'clk'), ('arst', 1, 'in'), ('w_load', 1, 'in'),
                       ('w_in', 8, 'in'), ('a_in', 8, 'in'), ('psum_in', 32, 'in'),
                       ('w_out', 8, 'out'), ('a_out', 8, 'out'), ('psum_out', 32, 'out'))),
    'SystolicArray': dict(manual_tb=True, inst='dut',
                          ports=P(('clk', 1, 'clk'), ('arst', 1, 'in'), ('w_load', 1, 'in'),
                                  ('w_data', 512, 'in'), ('a_data', 64, 'in'),
                                  ('psum_out', 256, 'out'))),
    'ShiftRegister': dict(manual_tb=True, inst='dut',
                          ports=P(('clk', 1, 'clk'), ('arst', 1, 'in'), ('en', 1, 'in'),
                                  ('in', 8, 'in'), ('out', 8, 'out'))),
}

MODULE = {
    'Not': 'n2t_not', 'And': 'n2t_and', 'Or': 'n2t_or', 'Xor': 'n2t_xor',
    'Mux': 'n2t_mux', 'DMux': 'n2t_dmux',
    'Not16': 'n2t_not16', 'And16': 'n2t_and16', 'Or16': 'n2t_or16',
    'Mux16': 'n2t_mux16', 'Or8Way': 'n2t_or8way',
    'Mux4Way16': 'n2t_mux4way16', 'Mux8Way16': 'n2t_mux8way16',
    'DMux4Way': 'n2t_dmux4way', 'DMux8Way': 'n2t_dmux8way',
    'HalfAdder': 'n2t_half_adder', 'FullAdder': 'n2t_full_adder',
    'Add16': 'n2t_add16', 'Inc16': 'n2t_inc16', 'ALU': 'n2t_alu',
    'Bit': 'n2t_bit', 'Register': 'n2t_register',
    'RAM8': 'n2t_ram8', 'RAM64': 'n2t_ram64', 'RAM512': 'n2t_ram512',
    'RAM4K': 'n2t_ram4k', 'RAM16K': 'n2t_ram16k', 'PC': 'n2t_pc',
    'CPU': 'n2t_cpu',
    'ComputerAdd': 'n2t_computer', 'ComputerMax': 'n2t_computer',
    'ComputerRect': 'n2t_computer',
    'PE': 'n2t_pe', 'SystolicArray': 'n2t_systolic_array',
    'ShiftRegister': 'n2t_shift_register',
}

PROJECT = {
    'Not': '01', 'And': '01', 'Or': '01', 'Xor': '01', 'Mux': '01', 'DMux': '01',
    'Not16': '01', 'And16': '01', 'Or16': '01', 'Mux16': '01', 'Or8Way': '01',
    'Mux4Way16': '01', 'Mux8Way16': '01', 'DMux4Way': '01', 'DMux8Way': '01',
    'HalfAdder': '02', 'FullAdder': '02', 'Add16': '02', 'Inc16': '02', 'ALU': '02',
    'Bit': '03', 'Register': '03', 'RAM8': '03', 'RAM64': '03', 'RAM512': '03',
    'RAM4K': '03', 'RAM16K': '03', 'PC': '03',
    'CPU': '05', 'ComputerAdd': '05', 'ComputerMax': '05', 'ComputerRect': '05',
    'PE': '06', 'SystolicArray': '06',
    'ShiftRegister': '06',
}


# ---------------------------------------------------------------------------
# .tst 解析
# ---------------------------------------------------------------------------
def parse_value(s):
    if s.startswith('%B'):
        return int(s[2:], 2)
    if s.startswith('%X'):
        return int(s[2:], 16)
    return int(s)


def parse_tst(path):
    """返回语句列表，每条语句为 (op, ...)。"""
    text = open(path, encoding='utf-8', errors='replace').read()
    # echo 文本里可能含逗号，必须先按行去掉整行
    lines = [ln for ln in text.splitlines()
             if ln.strip() and not ln.strip().startswith(('echo', 'clear-echo'))]
    text = re.sub(r'//[^\n]*', '', '\n'.join(lines))
    text = re.sub(r'\s+', ' ', text).strip()
    atoms = [a.strip() for a in re.split(r'([;,{}])', text) if a.strip()]

    stmts = []

    def parse_block(idx, out):
        while idx < len(atoms):
            a = atoms[idx]
            if a == '}':
                return idx + 1
            if a in (',', ';'):
                idx += 1
                continue
            if a == 'repeat' or a.startswith('repeat '):
                if a == 'repeat':
                    count = int(atoms[idx + 1])
                    j = idx + 2
                else:
                    count = int(a.split()[1])
                    j = idx + 1
                if atoms[j] != '{':
                    raise ValueError('repeat 后必须是 {')
                inner = []
                idx = parse_block(j + 1, inner)
                out.append(('repeat', count, inner))
                continue
            if a == 'while':
                raise ValueError('不支持 while（交互式测试请手工编写）: %s' % path)
            toks = a.split()
            op = toks[0]
            if op == 'output-list':
                out.append(('output-list', toks[1:]))
            elif op in ('load', 'ROM32K', 'output-file', 'compare-to'):
                pass
            elif op == 'set':
                out.append(('set', toks[1], parse_value(toks[2])))
            elif op == 'eval':
                out.append(('eval',))
            elif op == 'tick':
                out.append(('tick',))
            elif op == 'tock':
                out.append(('tock',))
            elif op == 'output':
                out.append(('output',))
            else:
                raise ValueError('无法识别的语句 %r（%s）' % (a, path))
            idx += 1
        return idx

    parse_block(0, stmts)
    return stmts


# ---------------------------------------------------------------------------
# .cmp 解析
# ---------------------------------------------------------------------------
def cell_to_int(cell, fmt):
    cell = cell.strip()
    if cell in ('*******', '*'):
        return None
    if fmt == 'B':
        return int(cell, 2)
    if fmt == 'X':
        return int(cell, 16)
    if fmt == 'D':
        return int(cell)
    raise ValueError('未知格式 %r: %r' % (fmt, cell))


def parse_cmp(path):
    rows = []
    for line in open(path, encoding='utf-8', errors='replace'):
        line = line.strip()
        if not line or not line.startswith('|'):
            continue
        rows.append([c.strip() for c in line.strip('|').split('|')])
    return rows


# ---------------------------------------------------------------------------
# 代码生成
# ---------------------------------------------------------------------------
def vconst(width, value):
    value &= (1 << width) - 1
    return "%d'h%x" % (width, value)


def vname(pin):
    # ARegister[0] -> ARegister_0, PC[] -> PC_, RAM16K[0] -> RAM16K_0
    return pin.replace('[', '_').replace(']', '')


def gen_tb(chip_name, cfg):
    tst_path = os.path.join(ROOT, cfg['tst'])
    cmp_path = os.path.join(ROOT, cfg['cmp'])
    stmts = parse_tst(tst_path)
    rows = parse_cmp(cmp_path)

    # 收集 output-list 的 (pin, fmt)
    raw_pins = []

    def count_outputs(lst):
        n = 0
        for st in lst:
            if st[0] == 'output':
                n += 1
            elif st[0] == 'repeat':
                n += st[1] * count_outputs(st[2])
        return n

    for st in stmts:
        if st[0] == 'output-list':
            raw_pins = [(t.split('%')[0], t.split('%')[1][0]) for t in st[1]]
    outputs = count_outputs(stmts)
    had_time = any(p[0] == 'time' for p in raw_pins)
    check_pins = [p for p in raw_pins if p[0] != 'time']

    m = re.search(r'ROM32K\s+load\s+([A-Za-z0-9_.-]+\.hack)', open(tst_path, encoding='utf-8').read())
    rom_file = os.path.join('programs', os.path.basename(m.group(1))) if m else None

    nrows = len(rows) - 1
    if nrows != outputs:
        raise SystemExit('%s: cmp 有 %d 行数据，tst 有 %d 个 output' % (chip_name, nrows, outputs))

    ports = cfg['ports']
    probes = cfg.get('probes', {})
    inst = cfg['inst']
    module = MODULE[chip_name]

    def pin_width(pin):
        for (name, w, d) in ports:
            if name == pin:
                return w
        if pin in probes:
            return probes[pin][1]
        raise KeyError(pin)

    def pin_expr(pin):
        for (name, w, d) in ports:
            if name == pin:
                return name
        if pin in probes:
            return probes[pin][0]
        raise KeyError(pin)

    # 期望值表：第 i 个 output 对应 table[i]，pin -> int|None
    table = []
    for r in rows[1:]:
        row = {}
        cells = r[1:] if had_time else r
        for (pin, fmt), cell in zip(check_pins, cells):
            row[pin] = cell_to_int(cell, fmt)
        table.append(row)

    L = []
    L.append('`timescale 1ns/1ps')
    L.append('')
    L.append('// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。')
    L.append('// 对应官方测试：%s / %s' % (cfg['tst'], cfg['cmp']))
    L.append('module %s_tb;' % chip_name)
    L.append('')

    # 信号声明
    for (name, w, d) in ports:
        if d == 'clk':
            L.append('    reg clk = 1\'b0;')
        elif d == 'in':
            L.append('    reg  [%d:0] %s = %s;' % (w - 1, name, vconst(w, 0)))
        else:
            L.append('    wire [%d:0] %s;' % (w - 1, name))
    L.append('')
    L.append('    integer step = 0;')
    L.append('    integer npass = 0, nfail = 0;')
    L.append('')

    # DUT 例化
    if chip_name.startswith('Computer'):
        rom_p = '.ROM_INIT_FILE("%s")' % rom_file if rom_file else '.ROM_INIT_FILE("")'
        L.append('    %s #(%s, .RAM_INIT_FILE("")) %s(' % (module, rom_p, inst))
    elif chip_name == 'RAM16K':
        L.append('    %s #(.INIT_FILE("")) %s(' % (module, inst))
    else:
        L.append('    %s %s(' % (module, inst))
    for idx, (name, w, d) in enumerate(ports):
        comma = ',' if idx < len(ports) - 1 else ''
        L.append('        .%s(%s)%s' % (name, name, comma))
    L.append('    );')
    L.append('')

    # 背板写任务
    if chip_name.startswith('Computer') or chip_name == 'RAM16K':
        L.append('    task backdoor_write;')
        L.append('        input [13:0] a;')
        L.append('        input [15:0] d;')
        L.append('        begin')
        L.append('            dbg_we = 1\'b1; dbg_addr = a; dbg_wdata = d; #1;')
        L.append('            dbg_we = 1\'b0;')
        L.append('        end')
        L.append('    endtask')
        L.append('')

    # 逐 pin 比对任务：参数为 (实际值, 期望值) 对
    L.append('    task tst_check;')
    for (pin, fmt) in check_pins:
        w = pin_width(pin)
        v = vname(pin)
        L.append('        input [%d:0] %s;' % (w - 1, v))
        L.append('        input [%d:0] exp_%s;' % (w - 1, v))
    L.append('        begin')
    for (pin, fmt) in check_pins:
        w = pin_width(pin)
        v = vname(pin)
        x = '{%d{1\'bx}}' % w
        L.append('            if (exp_%s === %s) begin' % (v, x))
        L.append('                npass = npass + 1;')
        L.append('            end else begin')
        L.append('                if (%s !== exp_%s) begin' % (v, v))
        dbg_fmt = ' '.join('%s=%%h exp=%%h' % p for p, _ in check_pins)
        dbg_args = ', '.join('%s, exp_%s' % (vname(p), vname(p)) for p, _ in check_pins)
        L.append('                    $display("FAIL [step %%0d] %%s: got %%h exp %%h    [%%s]", '
                 'step, "%s", %s, exp_%s, $sformatf("%s", %s));'
                 % (pin, v, v, dbg_fmt, dbg_args))
        L.append('                    nfail = nfail + 1;')
        L.append('                end else begin')
        L.append('                    npass = npass + 1;')
        L.append('                end')
        L.append('            end')
    L.append('        end')
    L.append('    endtask')
    L.append('')

    # VCD 波形（可选）
    L.append('`ifdef DUMP_VCD')
    L.append('    initial begin')
    L.append('        $dumpfile("sim/%s_tb.vcd");' % chip_name)
    L.append('        $dumpvars(0, %s);' % inst)
    L.append('    end')
    L.append('`endif')
    L.append('')

    # 激励序列
    L.append('    initial begin')
    L.append('        $display("=== %s ===");' % chip_name)
    row_idx = [0]

    def emit(st, indent):
        pad = '    ' * indent
        if st[0] == 'output-list':
            return
        if st[0] == 'set':
            pin = st[1]
            val = st[2]
            if pin.startswith('RAM16K['):
                addr = int(pin[7:-1])
                L.append('%sbackdoor_write(14\'d%d, %s);' % (pad, addr, vconst(16, val)))
            else:
                w = pin_width(pin)
                L.append('%s%s = %s;' % (pad, pin, vconst(w, val)))
        elif st[0] == 'eval':
            L.append('%s#10;' % pad)
        elif st[0] == 'tick':
            L.append('%s#1; clk = 1\'b1; #10;' % pad)
        elif st[0] == 'tock':
            L.append('%sclk = 1\'b0; #10;' % pad)
        elif st[0] == 'output':
            row = table[row_idx[0]]
            row_idx[0] += 1
            args = []
            for (pin, fmt) in check_pins:
                args.append(pin_expr(pin))
                exp = row[pin]
                w = pin_width(pin)
                if exp is None:
                    args.append('{%d{1\'bx}}' % w)
                else:
                    args.append(vconst(w, exp))
            L.append('%stst_check(%s);' % (pad, ', '.join(args)))
            L.append('%sstep = step + 1;' % pad)
        elif st[0] == 'repeat':
            # 展开循环：官方测试每个迭代的期望值不同，逐条展开最简单可靠
            for _ in range(st[1]):
                for inner in st[2]:
                    emit(inner, indent)
        else:
            raise ValueError(st)

    for st in stmts:
        emit(st, 1)

    L.append('')
    L.append('        if (nfail == 0)')
    L.append('            $display("PASS: all checks ok (total %0d)", npass);')
    L.append('        else')
    L.append('            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);')
    L.append('        $finish;')
    L.append('    end')
    L.append('endmodule')
    return '\n'.join(L)


def main():
    targets = sys.argv[1:] or sorted(CHIPS)
    for name in targets:
        cfg = CHIPS[name]
        if cfg.get('manual_tb'):
            print('skip (manual tb): %s' % name)
            continue
        tb_dir = os.path.join(ROOT, 'tb', PROJECT[name])
        os.makedirs(tb_dir, exist_ok=True)
        out = os.path.join(tb_dir, name + '_tb.v')
        with open(out, 'w', encoding='utf-8') as f:
            f.write(gen_tb(name, cfg))
        print('generated %s' % os.path.relpath(out, ROOT))


if __name__ == '__main__':
    main()
