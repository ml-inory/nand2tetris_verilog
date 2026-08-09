#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_problems.py — 从仓库自动生成在线判题题库 problems.json。

题库数据来源：
  - 端口/测试台/探针     tools/tst2tb.py 的 CHIPS/MODULE/PROJECT 配置
  - 初始代码             assignment/<proj>/<chip>.v（实现留空的作业模板）
  - 依赖模块             solution/ 下按例化关系 BFS 收集（判题时提供给编译）
  - 题目说明             solution 文件头部的注释块
  - 运行期文件           tb 中引用的 programs/*.hack（如 Computer 测试的机器码）

输出：server/problems.json（供后端判题服务使用）。
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(ROOT, 'tools'))

import tst2tb  # noqa: E402  (CHIPS / MODULE / PROJECT 配置)

SOL = os.path.join(ROOT, 'solution')
ASG = os.path.join(ROOT, 'assignment')
TB = os.path.join(ROOT, 'tb')
OUT = os.path.join(HERE, 'problems.json')

MODULE_RE = re.compile(r'\bmodule\s+(n2t_[a-z0-9_]+)')
COMMENT_RE = re.compile(r'//[^\n]*|/\*.*?\*/', re.S)


def strip_comments(text):
    return COMMENT_RE.sub('', text)


def module_file_map():
    """module 名 -> 定义它的 .v 文件（relative to ROOT）。"""
    m = {}
    for dirpath, _, files in os.walk(SOL):
        for fn in sorted(files):
            if not fn.endswith('.v'):
                continue
            path = os.path.join(dirpath, fn)
            for name in MODULE_RE.findall(strip_comments(open(path, encoding='utf-8').read())):
                m[name] = os.path.relpath(path, ROOT)
    return m


def collect_deps(chip):
    """依赖 = 所有其他已发布模块的文件（按模块名去重，排除自身）。

    学生可以按任意合法结构实现（例化更小的 n2t_* 模块，如 Mux8Way16 例化
    Mux4Way16），因此 deps 不限于 solution 的实际例化关系：后面的题应能
    引用前面任何模块。同模块名（如 Computer 三变体都叫 n2t_computer）
    只保留一个定义文件，且不包含用户自己要实现的模块。
    """
    modmap = module_file_map()
    own = tst2tb.MODULE[chip]
    return sorted({f for name, f in modmap.items() if name != own})


def read_header_comment(path):
    """取 module 前的连续 // 注释块作为题目说明。"""
    text = open(path, encoding='utf-8').read()
    m = re.search(r'(?:^|\n)((?:[ \t]*//[^\n]*\n)+)[ \t]*module\b', text)
    if not m:
        return ''
    lines = []
    for ln in m.group(1).splitlines():
        ln = re.sub(r'^\s*//\s?', '', ln)
        if ln.strip():
            lines.append(ln.strip())
    return '\n'.join(lines)


def runtime_files(tb_path):
    """tb 里 ROM_INIT_FILE("programs/xxx.hack") 引用的运行期文件。"""
    text = open(tb_path, encoding='utf-8').read()
    return sorted(set(re.findall(r'ROM_INIT_FILE\("([^"]+)"\)', text)))


def main():
    problems = []
    for chip in tst2tb.CHIPS:
        cfg = tst2tb.CHIPS[chip]
        proj = tst2tb.PROJECT[chip]
        module = tst2tb.MODULE[chip]
        fname = 'Computer.v' if proj == '05' and chip.startswith('Computer') else chip + '.v'
        sol_file = os.path.join(SOL, proj, fname)
        asg_file = os.path.join(ASG, proj, fname)
        tb_file = os.path.join(TB, proj, chip + '_tb.v')
        wave_file = os.path.join(HERE, 'wave_tb', proj, chip + '.v')
        assert os.path.exists(sol_file), sol_file
        assert os.path.exists(asg_file), asg_file
        assert os.path.exists(tb_file), tb_file

        ports = [{'name': n, 'width': w, 'dir': d} for (n, w, d) in cfg['ports']]
        probes = [{'name': k, 'width': v[1]} for k, v in (cfg.get('probes') or {}).items()]
        problems.append({
            'id': chip,
            'title': chip,
            'project': proj,
            'module': module,
            'ports': ports,
            'probes': probes,
            'description': read_header_comment(sol_file),
            'initial_code': open(asg_file, encoding='utf-8').read(),
            'deps': collect_deps(chip),
            'tb': os.path.relpath(tb_file, ROOT),
            'tb_top': chip + '_tb',
            'wave_tb': os.path.relpath(wave_file, ROOT),
            'runtime_files': runtime_files(tb_file),
        })

    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump({'problems': problems}, f, ensure_ascii=False, indent=2)
    print(f'wrote {OUT} ({len(problems)} problems)')


if __name__ == '__main__':
    main()
