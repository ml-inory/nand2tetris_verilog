#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""debug_sim.py — 用学生实际代码跑 SystolicArray 逐拍仿真。

原理：
  1. 把学生代码 + 依赖 + 调试 testbench 用 iverilog 编译；
  2. vvp 运行并 dump 全部内部信号（wave.vcd）；
  3. 解析 VCD：找到每个 PE 的 w / a / psum 信号；
  4. 在每个 clk 上升沿采样，生成逐拍状态 JSON。

支持两种 PE 层级命名：
  - 参考实现：dut.gen_row[r].gen_col[c].u_pe.w
  - 学生扁平实现：dut.genblk1[i].PE.w（i -> row=i/N, col=i%N）
"""
import os
import re
import shutil
import tempfile

from .judge import _run, IVERILOG, VVP, ROOT, BY_ID, normalize_code
DEBUG_N = 4

DEBUG_TB = r'''
`timescale 1ns/1ps
module SystolicArray_debug_tb;
    localparam N = 4;
    reg clk = 1'b0;
    reg arst = 1'b1;
    reg w_load = 1'b0;
    reg [N*N*8-1:0] w_data = 0;
    reg [N*8-1:0] a_data = 0;
    wire [N*32-1:0] psum_out;
    integer k;

    n2t_systolic_array #(.N(N)) dut(
        .clk(clk), .arst(arst), .w_load(w_load),
        .w_data(w_data), .a_data(a_data), .psum_out(psum_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dut);
        repeat (2) @(posedge clk);
        arst = 0; #1;
        w_load = 1;
        w_data = 128'h0102030405060708090a0b0c0d0e0f10;
        @(posedge clk); #1;
        w_load = 0;
        for (k = 0; k < 8; k = k + 1) begin
            a_data = 32'h04030201;
            @(posedge clk); #1;
        end
        repeat (N-1) @(posedge clk); #1;
        $finish;
    end
endmodule
'''


def _value_at(events, t):
    events = sorted(events, key=lambda x: x[0])
    v = None
    for tt, val in events:
        if tt > t:
            break
        v = val
    return v


def _to_int(val):
    if val is None:
        return 0
    s = str(val)
    if s.startswith('b'):
        s = s[1:]
    if not re.fullmatch(r'[01xz]+', s):
        return 0
    if 'x' in s or 'z' in s:
        return 0
    w = len(s)
    v = int(s, 2)
    if w and v >= (1 << (w - 1)):
        v -= (1 << w)
    return v


def _parse_vcd_full(path):
    """解析 VCD 并保留完整层级名（$scope/$upscope）。"""
    var_order = []
    events = {}
    scope = []
    cur = 0
    in_defs = True
    for line in open(path, 'r', encoding='utf-8', errors='replace'):
        line = line.strip()
        if not line:
            continue
        if line.startswith('$scope'):
            parts = line.split()
            if len(parts) >= 3:
                scope.append(parts[2])
            continue
        if line.startswith('$upscope'):
            if scope:
                scope.pop()
            continue
        if line.startswith('$var'):
            parts = line.split()
            if len(parts) >= 5:
                vid = parts[3]
                name = parts[4]
                full = '.'.join(scope + [name]) if scope else name
                var_order.append((vid, full))
                events[vid] = []
            continue
        if line.startswith('$enddefinitions'):
            in_defs = False
            continue
        if in_defs:
            continue
        if line.startswith('#'):
            cur = int(line[1:])
        elif line.startswith('b'):
            m = re.match(r'b([01xzXZ]+)\s+(\S+)', line)
            if m:
                vid = m.group(2)
                if vid in events:
                    events[vid].append((cur, m.group(1).lower()))
        elif len(line) >= 2 and line[0] in '01xXzZ' and line[1] in events:
            events[line[1]].append((cur, line[0].lower()))
    return var_order, events


def _slice_vec(val, width, index):
    """从 MSB-first 二进制向量里取第 index 个 width 位字，返回带符号整数。"""
    s = str(val or '')
    if s.startswith('b'):
        s = s[1:]
    if not re.fullmatch(r'[01xz]+', s):
        return 0
    total = len(s)
    start = total - (index + 1) * width
    if start < 0:
        return 0
    part = s[start:start + width]
    if 'x' in part or 'z' in part:
        return 0
    v = int(part, 2)
    if v >= (1 << (width - 1)):
        v -= (1 << width)
    return v


def debug_sim(problem_id, code):
    if problem_id != 'SystolicArray':
        return {'error': '逐拍仿真目前只支持 SystolicArray'}
    p = BY_ID.get(problem_id)
    if p is None:
        return {'error': 'unknown problem'}

    code, friendly = normalize_code(p, code)
    if friendly:
        return {'error': friendly}

    workdir = tempfile.mkdtemp(prefix='n2t_debug_')
    try:
        with open(os.path.join(workdir, 'user.v'), 'w', encoding='utf-8') as f:
            f.write(code)
        dep_files = []
        for i, dep in enumerate(p['deps']):
            dst = os.path.join(workdir, 'dep%d_%s' % (i, os.path.basename(dep)))
            shutil.copy(os.path.join(ROOT, dep), dst)
            dep_files.append(dst)
        tb_path = os.path.join(workdir, 'tb.v')
        with open(tb_path, 'w', encoding='utf-8') as f:
            f.write(DEBUG_TB)

        cmd = [IVERILOG, '-g2012', '-s', 'SystolicArray_debug_tb',
               '-o', 'out.vvp', 'user.v'] + dep_files + ['tb.v']
        rc, out, _ = _run(cmd, workdir, 20)
        if rc != 0:
            return {'error': 'compile failed', 'log': out[-3000:]}

        rc, out, _ = _run([VVP, 'out.vvp'], workdir, 30)
        if rc != 0:
            return {'error': 'simulation failed', 'log': out[-3000:]}

        var_order, events = _parse_vcd_full(os.path.join(workdir, 'wave.vcd'))
        return _parse_states(var_order, events)
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


def _parse_states(var_order, events):
    N = DEBUG_N
    pe_map = {}
    clk_id = None
    a_id = None
    pout_id = None

    for vid, name in var_order:
        if 'dut.' not in name:
            continue
        if name.endswith('.clk'):
            clk_id = vid
        if name == 'dut.a_data' or name.endswith('.a_data'):
            a_id = vid
        if name.endswith('.dut.psum_out'):
            pout_id = vid

        m = re.search(r'gen_row\[(\d+)\].*?gen_col\[(\d+)\]', name)
        if m:
            r, c = int(m.group(1)), int(m.group(2))
        else:
            m = re.search(r'genblk1?\[(\d+)\]', name)
            if m:
                idx = int(m.group(1))
                r, c = idx // N, idx % N
            else:
                continue
        tail = name.rsplit('.', 1)[-1]
        entry = pe_map.setdefault((r, c), {})
        if tail == 'w':
            entry['w'] = vid
        elif tail in ('a_out', 'a_in'):
            entry.setdefault('a', vid)
        elif tail in ('psum_out', 'psum_in'):
            entry.setdefault('p', vid)

    if not pe_map:
        return {'error': '无法识别 PE 内部信号。请保持 gen_row[r].gen_col[c].u_pe '
                         '或 genblk[i].PE 的实例命名，否则逐拍仿真无法可视化。'}
    if clk_id is None:
        return {'error': 'VCD 里找不到 clk 信号'}

    clk_times = [t for t, v in events.get(clk_id, []) if str(v) in ('1', 'b1')]
    states = []
    for ci, t in enumerate(clk_times[:24]):
        a_data = []
        if a_id is not None:
            val = _value_at(events.get(a_id, []), t)
            a_data = [_slice_vec(val, 8, r) for r in range(N)]
        psum_out = []
        if pout_id is not None:
            val = _value_at(events.get(pout_id, []), t)
            psum_out = [_slice_vec(val, 32, c) for c in range(N)]
        pes = []
        for (r, c), ids in sorted(pe_map.items()):
            pes.append({
                'row': r, 'col': c,
                'w': _to_int(_value_at(events.get(ids.get('w'), []), t)),
                'a': _to_int(_value_at(events.get(ids.get('a'), []), t)),
                'p': _to_int(_value_at(events.get(ids.get('p'), []), t)),
            })
        states.append({'cycle': ci, 'aData': a_data, 'psumOut': psum_out, 'pes': pes})
    return {'N': N, 'states': states, 'peCount': len(pe_map)}
