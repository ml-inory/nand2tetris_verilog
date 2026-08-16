#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
wave.py — 波形：跑“波形演示 testbench”生成 wave.vcd，解析成 WaveDrom JSON。

- 默认：只 dump 端口信号，VCD 很小（判题结果自动附带的波形）。
- 调试：可按用户指定信号路径（如 mem[5]、u1.u_ab.out）动态 dump 内部信号，
  $dumpvars 直接引用 dut.<path>，iverilog 支持数组元素与子模块层次路径。
返回结构（WaveDrom 兼容）：
    {'signal': [{'name': 'a', 'wave': '01.10'}, {'name': 'out', 'wave': '=..=', 'data': ['0','f']}]}
"""
import os
import re

from .judge import _run, IVERILOG, VVP, ROOT

HEX = '0123456789abcdef'


def parse_vcd(path):
    """返回 (var_order, events)。

    var_order: [(vcd_id, name), ...]，按 $var 声明顺序（与 $dumpvars 参数顺序一致，
    可用来消歧同名信号，如 dut.g_mux.out 与 dut.out 都叫 out）。
    events: {vcd_id: [(time, value_str), ...]}。
    """
    var_order = []
    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith('$var'):
                # $var wire 16 ! name $end
                parts = line.split()
                if len(parts) >= 5:
                    var_order.append((parts[3], parts[4]))
            elif line.startswith('$enddefinitions'):
                break
    events = {vid: [] for vid, _ in var_order}

    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            line = line.strip()
            if not line:
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
    return var_order, {k: v for k, v in events.items() if v}


def _to_hex(binstr):
    """二进制串（可能含 x/z）-> 小写十六进制串。"""
    while len(binstr) % 4:
        binstr = '0' + binstr
    out = []
    for i in range(0, len(binstr), 4):
        nib = binstr[i:i + 4]
        if 'x' in nib:
            out.append('x')
        elif 'z' in nib:
            out.append('z')
        else:
            out.append(HEX[int(nib, 2)])
    return ''.join(out)


def to_wavedrom(events, var_order, display_names=None):
    """按 $var 声明顺序生成 WaveDrom signal 行；display_names 为显示名（消歧重名）。"""
    if display_names is None:
        display_names = [name for _, name in var_order]
    times = sorted(set(t for ev in events.values() for (t, _) in ev))
    rows = []
    for i, (vid, name) in enumerate(var_order):
        ev = events.get(vid, [])
        if not ev:
            continue
        label = display_names[i] if i < len(display_names) else name
        idx = 0
        wave = []
        data = []
        for t in times:
            if idx < len(ev) and ev[idx][0] == t:
                val = ev[idx][1]
                idx += 1
            # 保持 idx 指向 >= 当前时间的事件
            while idx < len(ev) and ev[idx][0] <= t:
                idx += 1
            if len(val) == 1 and val in '01xz':
                wave.append(val)
            elif len(val) == 1:
                wave.append('x')
            else:
                wave.append('=')
                data.append(_to_hex(val))
        row = {'name': label, 'wave': ''.join(wave)}
        if data:
            row['data'] = data
        rows.append(row)
    return {'signal': rows}


def run_wave(prob, workdir):
    """在已有 user.v + 依赖模块的 workdir 里跑波形 tb，返回 WaveDrom JSON（失败返回 None）。"""
    import shutil
    wave_tb = os.path.join(workdir, 'wave_tb.v')
    shutil.copy(os.path.join(ROOT, prob['wave_tb']), wave_tb)
    cmd = [IVERILOG, '-g2012', '-s', prob['id'] + '_wave_tb', '-o', 'wave.vvp',
           'user.v', 'wave_tb.v'] + sorted(f for f in os.listdir(workdir) if f.startswith('dep'))
    rc, out, err = _run(cmd, workdir, 15)
    if rc != 0:
        return None
    rc, out, err = _run([VVP, 'wave.vvp'], workdir, 30)
    if rc != 0:
        return None
    vcd = os.path.join(workdir, 'wave.vcd')
    if not os.path.exists(vcd):
        return None
    var_order, events = parse_vcd(vcd)
    ports = [p['name'] for p in prob['ports']]
    # 端口名 -> 按声明顺序对齐
    names = [name for _, name in var_order]
    disp = [ports[names.index(n)] if n in ports else n for n in names]
    return to_wavedrom(events, var_order, disp)


def run_wave_for_code(problem_id, code, signals):
    """按用户指定信号路径（如 mem[5]、g_mux.out）跑波形，返回 WaveDrom JSON。

    返回 {'signal': [...]} 成功，{'error': '...'} 失败（信号路径无效等）。
    """
    import shutil
    import tempfile
    from .judge import BY_ID, normalize_code

    prob = BY_ID.get(problem_id)
    if prob is None:
        return {'error': 'unknown problem'}
    code, friendly = normalize_code(prob, code)
    if friendly:
        return {'error': friendly}

    workdir = tempfile.mkdtemp(prefix='n2t_wave_')
    try:
        with open(os.path.join(workdir, 'user.v'), 'w', encoding='utf-8') as f:
            f.write(code)
        for i, dep in enumerate(prob['deps']):
            shutil.copy(os.path.join(ROOT, dep),
                        os.path.join(workdir, f'dep{i}_{os.path.basename(dep)}'))
        # 读原 wave_tb，把端口 dump 换成用户指定的内部信号路径
        tb = open(os.path.join(ROOT, prob['wave_tb']), encoding='utf-8').read()
        dump = ', '.join('dut.%s' % s for s in signals)
        tb = re.sub(r'\$dumpvars\(0,[^;]*\);', '$dumpvars(0, %s);' % dump, tb)
        with open(os.path.join(workdir, 'wave_tb.v'), 'w', encoding='utf-8') as f:
            f.write(tb)

        dep_files = sorted(f for f in os.listdir(workdir) if f.startswith('dep'))
        cmd = [IVERILOG, '-g2012', '-s', prob['id'] + '_wave_tb', '-o', 'wave.vvp',
               'user.v', 'wave_tb.v'] + dep_files
        rc, out, err = _run(cmd, workdir, 15)
        if rc != 0:
            # 提取具体无效的信号路径
            bad = re.search(r"Unable to bind [^`]*`([^']+)", out)
            if bad:
                return {'error': '信号路径无效：%s（请按模块内部结构填写，如 mem[5]、实例名.out）' % bad.group(1)}
            return {'error': '编译失败：' + (out.strip()[-300:])}
        rc, out, err = _run([VVP, 'wave.vvp'], workdir, 30)
        if rc != 0:
            return {'error': '仿真失败：' + (out.strip()[-300:])}
        vcd = os.path.join(workdir, 'wave.vcd')
        if not os.path.exists(vcd):
            return {'error': '未生成波形'}
        var_order, events = parse_vcd(vcd)
        return to_wavedrom(events, var_order, signals)
    finally:
        shutil.rmtree(workdir, ignore_errors=True)
