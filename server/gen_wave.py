#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_wave.py — 为每道题生成“波形演示” testbench。

与官方 testbench 的区别：
  - 激励取官方 .tst 开头若干条 set/tick/tock/eval（跳过 output 比对）；
  - $dumpvars 只 dump 端口信号（顶层），不会像官方 tb 那样 dump 整个 dut
    层级（否则 RAM16K 的 mem[16384] 会让 VCD 爆炸）；
  - 输出 wave.vcd，供判题服务转成 WaveDrom JSON 在前端画波形。

输出：server/wave_tb/<proj>/<chip>.v；路径由 gen_problems.py 写入题库。
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(ROOT, 'tools'))

import tst2tb  # noqa: E402

MAX_OPS = 16  # 波形激励条数上限（太多会让波形图很长）


def collect_ops(stmts):
    """取前 MAX_OPS 条驱动类语句（set/eval/tick/tock），展开 repeat。"""
    ops = []

    def walk(lst):
        for st in lst:
            if len(ops) >= MAX_OPS:
                return
            if st[0] in ('output-list', 'output'):
                continue
            if st[0] == 'repeat':
                for _ in range(st[1]):
                    walk(st[2])
                    if len(ops) >= MAX_OPS:
                        return
            else:
                ops.append(st)
    walk(stmts)
    return ops


def gen_wave_tb(chip_name, cfg):
    module = tst2tb.MODULE[chip_name]
    inst = cfg['inst']
    ports = cfg['ports']
    if cfg.get('manual_tb'):
        return gen_manual_wave_tb(chip_name, cfg)
    stmts = collect_ops(tst2tb.parse_tst(os.path.join(ROOT, cfg['tst'])))

    m = re.search(r'ROM32K\s+load\s+([A-Za-z0-9_.-]+\.hack)',
                  open(os.path.join(ROOT, cfg['tst']), encoding='utf-8').read())
    rom_file = os.path.join('programs', os.path.basename(m.group(1))) if m else None

    L = []
    L.append('`timescale 1ns/1ps')
    L.append('')
    L.append('// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。')
    L.append('module %s_wave_tb;' % chip_name)
    L.append('')
    for (name, w, d) in ports:
        if d == 'clk':
            L.append('    reg clk = 1\'b0;')
        elif d == 'in':
            L.append('    reg  [%d:0] %s = %s;' % (w - 1, name, tst2tb.vconst(w, 0)))
        else:
            L.append('    wire [%d:0] %s;' % (w - 1, name))
    L.append('')

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

    L.append('    initial begin')
    L.append('        $dumpfile("wave.vcd");')
    L.append('        $dumpvars(0, %s);' % ', '.join(p[0] for p in ports))
    L.append('')
    has_clk = any(d == 'clk' for (_, _, d) in ports)
    prev_set = False
    for st in stmts:
        if st[0] == 'set':
            pin, val = st[1], st[2]
            if pin.startswith('RAM16K['):
                addr = int(pin[7:-1])
                L.append("        backdoor_write(14'd%d, %s);" % (addr, tst2tb.vconst(16, val)))
            else:
                w = next(p[1] for p in ports if p[0] == pin)
                if prev_set and not has_clk:
                    L.append('        #10;   // 组合电路：让每个输入步在波形里可见')
                L.append('        %s = %s;' % (pin, tst2tb.vconst(w, val)))
            prev_set = True
        elif st[0] == 'eval':
            L.append('        #10;')
            prev_set = False
        elif st[0] == 'tick':
            L.append('        #1; clk = 1\'b1; #10;')
            prev_set = False
        elif st[0] == 'tock':
            L.append('        clk = 1\'b0; #10;')
    L.append('        #10;')
    L.append('        $finish;')
    L.append('    end')
    L.append('endmodule')
    return '\n'.join(L)


def gen_manual_wave_tb(chip_name, cfg):
    """手工 testbench 题目的波形演示：不解析 .tst，直接给一组简单激励。"""
    module = tst2tb.MODULE[chip_name]
    inst = cfg['inst']
    ports = cfg['ports']

    L = []
    L.append('`timescale 1ns/1ps')
    L.append('')
    L.append('// 波形演示激励（手工 testbench 自动生成）：只驱动端口、只 dump 端口。')
    L.append('module %s_wave_tb;' % chip_name)
    L.append('')
    for (name, w, d) in ports:
        if d == 'clk':
            L.append('    reg clk = 1\'b0;')
        elif d == 'in':
            L.append('    reg  [%d:0] %s = %s;' % (w - 1, name, tst2tb.vconst(w, 0)))
        else:
            L.append('    wire [%d:0] %s;' % (w - 1, name))
    L.append('')
    L.append('    %s %s(' % (module, inst))
    for idx, (name, w, d) in enumerate(ports):
        comma = ',' if idx < len(ports) - 1 else ''
        L.append('        .%s(%s)%s' % (name, name, comma))
    L.append('    );')
    L.append('')
    L.append('    initial begin')
    L.append('        $dumpfile("wave.vcd");')
    L.append('        $dumpvars(0, %s);' % ', '.join(p[0] for p in ports))
    L.append('')
    L.append('        // 简单激励：先复位两拍，再载入数据，最后再跑两拍')
    L.append('        #5;')
    for (name, w, d) in ports:
        if d == 'in' and name == 'rst':
            L.append('        rst = 1;')
    L.append('        #10;')
    for (name, w, d) in ports:
        if d == 'in' and name != 'rst':
            L.append('        %s = %s;' % (name, tst2tb.vconst(w, (name == 'w_load') and 1 or 3)))
    L.append('        #10;')
    for (name, w, d) in ports:
        if d == 'clk':
            L.append('        clk = 1;')
    L.append('        #10;')
    for (name, w, d) in ports:
        if d == 'clk':
            L.append('        clk = 0;')
    L.append('        #10;')
    for (name, w, d) in ports:
        if d == 'in' and name == 'rst':
            L.append('        rst = 0;')
    for (name, w, d) in ports:
        if d == 'in' and name == 'w_load':
            L.append('        w_load = 0;')
    L.append('        #10;')
    for (name, w, d) in ports:
        if d == 'clk':
            L.append('        clk = 1;')
    L.append('        #10;')
    L.append('        $finish;')
    L.append('    end')
    L.append('endmodule')
    return '\n'.join(L)


def main():
    targets = sys.argv[1:] or sorted(tst2tb.CHIPS)
    for name in targets:
        cfg = tst2tb.CHIPS[name]
        out_dir = os.path.join(HERE, 'wave_tb', tst2tb.PROJECT[name])
        os.makedirs(out_dir, exist_ok=True)
        out = os.path.join(out_dir, name + '.v')
        with open(out, 'w', encoding='utf-8') as f:
            f.write(gen_wave_tb(name, cfg))
        print('generated %s' % os.path.relpath(out, ROOT))


if __name__ == '__main__':
    main()
