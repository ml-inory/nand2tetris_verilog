#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
judge.py — 判题核心：把学生代码 + 依赖模块 + 官方 testbench 组装后跑 iverilog/vvp。

流程：
  1. 在临时目录写入学生代码 user.v
  2. 拷贝依赖模块（solution 里按例化关系收集）与官方 testbench
  3. 拷贝 tb 引用的运行期文件（programs/*.hack）
  4. iverilog -g2012 编译；失败 -> status=error + 编译日志
  5. vvp 仿真；解析 PASS/FAIL 输出
  6. 全程超时 + 资源限制（进程组 kill，防失控仿真）
"""
import json
import os
import re
import resource
import shutil
import signal
import subprocess
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
SERVER = os.path.dirname(HERE)
ROOT = os.path.dirname(SERVER)

PROBLEMS = json.load(open(os.path.join(SERVER, 'problems.json'), encoding='utf-8'))['problems']
BY_ID = {p['id']: p for p in PROBLEMS}

IVERILOG = os.environ.get('IVERILOG', 'iverilog')
VVP = os.environ.get('VVP', 'vvp')
COMPILE_TIMEOUT = 15      # 秒
RUN_TIMEOUT = 60          # 秒（Computer 全程序测试较慢）
MAX_CODE = 64 * 1024      # 学生代码上限

PASS_SUM_RE = re.compile(r'PASS: all checks ok \(total (\d+)\)')
FAIL_SUM_RE = re.compile(r'FAIL: (\d+) errors out of (\d+) checks')


def _limits():
    """子进程资源限制：CPU 时间、地址空间、输出文件大小。"""
    def fn():
        resource.setrlimit(resource.RLIMIT_CPU, (30, 30))
        resource.setrlimit(resource.RLIMIT_AS, (1 << 30, 1 << 30))        # 1 GiB
        resource.setrlimit(resource.RLIMIT_FSIZE, (512 << 20, 512 << 20))  # 512 MiB
    return fn


def _run(cmd, cwd, timeout):
    proc = subprocess.Popen(
        cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, errors='replace', start_new_session=True, preexec_fn=_limits(),
    )
    try:
        out, _ = proc.communicate(timeout=timeout)
        return proc.returncode, out, None
    except subprocess.TimeoutExpired:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        proc.wait()
        return None, '', 'timeout'


MODULE_DECL_RE = re.compile(r'\bmodule\s+(\w+)')


def module_header(prob):
    """从初始模板里提取 module 声明头（含参数与端口列表，直到第一个 );）。"""
    m = re.search(r'\bmodule\b[\s\S]*?\)\s*;', prob['initial_code'])
    return m.group(0) if m else 'module %s ();' % prob['module']


def body_is_empty(prob, code):
    """去掉注释/指令/模块头/endmodule 后没有内容 -> 实现体为空。"""
    text = re.sub(r'//[^\n]*|/\*.*?\*/', '', code, flags=re.S)
    text = re.sub(r'`[^\n]*', '', text)
    text = re.sub(r'\bmodule\b[\s\S]*?\)\s*;', '', text, count=1)
    text = re.sub(r'\bendmodule\b', '', text)
    return not re.sub(r'\s+', '', text)


def normalize_code(prob, code):
    """返回 (规范后的代码, 友好错误或 None)。

    - 已包含正确模块声明 -> 原样返回
    - 模块名写错 -> 返回友好错误（不自动改）
    - 完全没有模块声明（只写了实现体，如 assign out = ~in;）-> 自动用
      模板的模块头包裹成完整模块，避免初学者把模板删掉后直接报语法错误
    """
    m = MODULE_DECL_RE.search(code)
    if m:
        if m.group(1) == prob['module']:
            if body_is_empty(prob, code):
                return code, ('还没有填写实现：请在 module 内添加逻辑，'
                              '例如 assign out = ~in;。也可以只提交这一行实现，系统会自动补齐模块声明。')
            return code, None
        return code, '模块名应为 %s（你写的是 %s）——请保留模板里的 module 声明，只填写实现' % (
            prob['module'], m.group(1))
    wrapped = '%s\n\n%s\n\nendmodule' % (module_header(prob), code)
    return wrapped, None


def judge(problem_id, code):
    t0 = time.time()
    prob = BY_ID.get(problem_id)
    if prob is None:
        return {'status': 'error', 'error': f'unknown problem: {problem_id}'}
    if not code or len(code) > MAX_CODE:
        return {'status': 'error', 'error': f'code size {len(code or "")} bytes (max {MAX_CODE})'}

    result = {'status': 'error', 'compile': None, 'summary': None, 'log': '',
              'time_ms': None, 'error': None}
    workdir = tempfile.mkdtemp(prefix='n2t_judge_')
    try:
        # ---- 组装文件 ----
        code, friendly = normalize_code(prob, code)
        if friendly:
            result['status'] = 'error'
            result['error'] = friendly
            return result
        with open(os.path.join(workdir, 'user.v'), 'w', encoding='utf-8') as f:
            f.write(code)
        for i, dep in enumerate(prob['deps']):
            shutil.copy(os.path.join(ROOT, dep), os.path.join(workdir, f'dep{i}_{os.path.basename(dep)}'))
        shutil.copy(os.path.join(ROOT, prob['tb']), os.path.join(workdir, 'tb.v'))
        for rf in prob['runtime_files']:
            dst = os.path.join(workdir, rf)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy(os.path.join(ROOT, rf), dst)

        # ---- 编译 ----
        dep_files = sorted(f for f in os.listdir(workdir) if f.startswith('dep'))
        cmd = [IVERILOG, '-g2012', '-s', prob['tb_top'], '-o', 'out.vvp',
               'user.v'] + dep_files + ['tb.v']
        rc, out, err = _run(cmd, workdir, COMPILE_TIMEOUT)
        if err == 'timeout':
            result['error'] = 'compile timeout'
            return result
        if rc != 0:
            result['status'] = 'error'
            result['compile'] = {'ok': False, 'log': out.strip()}
            return result
        result['compile'] = {'ok': True, 'log': ''}

        # ---- 仿真 ----
        rc, out, err = _run([VVP, 'out.vvp'], workdir, RUN_TIMEOUT)
        if err == 'timeout':
            result['status'] = 'error'
            result['error'] = 'simulation timeout'
            result['log'] = out[-4000:]
            return result
        result['log'] = out.strip()

        m = PASS_SUM_RE.search(out)
        if m:
            result['status'] = 'pass'
            result['summary'] = {'total': int(m.group(1)), 'passed': int(m.group(1)), 'failed': 0}
        else:
            m = FAIL_SUM_RE.search(out)
            if m:
                nfail, ntotal = int(m.group(1)), int(m.group(2))
                result['status'] = 'fail'
                result['summary'] = {'total': ntotal, 'passed': ntotal - nfail, 'failed': nfail}
            else:
                result['status'] = 'error'
                result['error'] = 'no test summary in output'
                return result

        # 附带波形（只 dump 端口，VCD 很小；失败不影响判题结果）
        try:
            from .wave import run_wave
            result['wave'] = run_wave(prob, workdir)
        except Exception:
            result['wave'] = None
        return result
    finally:
        shutil.rmtree(workdir, ignore_errors=True)
        result['time_ms'] = int((time.time() - t0) * 1000)
