#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_assignment.py — 从 solution/ 的完整实现生成 assignment/ 作业模板。

作业模板保留文件头注释与模块端口声明，把实现部分替换为 TODO 占位，
学生只需补全实现，再跑 `make sim-0X RTLDIR=assignment` 验证。

用法：
    python3 tools/gen_assignment.py      # 重新生成全部作业
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SOL = os.path.join(ROOT, 'solution')
ASG = os.path.join(ROOT, 'assignment')

TODO = "    // ==================== 作业：请补全本模块实现 ====================\n" \
    "    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。\n" \
    "    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；\n" \
    "    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。\n"

TODO_06 = "    // ==================== 作业：请补全本模块实现 ====================\n" \
    "    // 提示：参考 docs/npu.md 与 solution/06/ 的完整实现。\n" \
    "    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；\n" \
    "    // 完成后执行 `make sim-06 RTLDIR=assignment` 验证。\n"

# 测试台会用层级路径读取以下内部信号（对应官方测试的 ARegister[]/DRegister[]/
# PC[]/RAM16K[] 探针）。骨架里保留这些声明/例化，保证留空作业也能编译；
# 学生补全逻辑时必须保留这些命名（与课程要求部件名一致）。
SKELETONS = {
    'n2t_cpu': '''    // 测试台按层级路径读取 cpu.a_reg / cpu.d_reg / cpu.pc_reg，\n    // 请保留这三个寄存器命名（对应课程中的 ARegister / DRegister / PC）。\n    reg [15:0] a_reg;\n    reg [15:0] d_reg;\n    reg [14:0] pc_reg;\n''',
    'n2t_ram16k': '''    // 测试台按层级路径读取 u_comp.u_mem.u_ram.mem[i]，\n    // 存储数组必须命名为 mem（对应课程内置 RAM16K）。\n    reg [15:0] mem [0:16383];\n''',
    'n2t_memory': '''    // 测试台按层级路径读取 u_mem.u_ram.mem[i]，RAM16K 例化名必须为 u_ram。\n    // 请补全：地址译码（load_ram）、Screen/Keyboard 映射与输出选择。\n    wire        load_ram;\n    wire [15:0] ram_out;\n\n    n2t_ram16k #(.INIT_FILE(RAM_INIT_FILE)) u_ram(\n        .clk(clk), .in(in), .load(load_ram), .address(address),\n        .dbg_we(dbg_we), .dbg_addr(dbg_addr), .dbg_wdata(dbg_wdata),\n        .out(ram_out)\n    );\n''',
    'n2t_computer': '''    // Computer 就是把 ROM / CPU / Memory 三块部件接起来（接线本身也是作业，\n    // 但必须保留例化名 u_rom / u_cpu / u_mem：测试台按层级路径读取内部寄存器与内存）。\n    wire [15:0] instr, inM;\n\n    n2t_rom32k #(.INIT_FILE(ROM_INIT_FILE)) u_rom(\n        .address(pc), .out(instr)\n    );\n\n    n2t_cpu u_cpu(\n        .clk(clk), .inM(inM), .instruction(instr), .reset(reset),\n        .outM(outM), .writeM(writeM), .addressM(addressM), .pc(pc)\n    );\n\n    n2t_memory #(.RAM_INIT_FILE(RAM_INIT_FILE)) u_mem(\n        .clk(clk), .in(outM), .load(writeM), .address(addressM),\n        .keyboard_in(16'h0000),\n        .dbg_we(dbg_we), .dbg_addr(dbg_addr), .dbg_wdata(dbg_wdata),\n        .out(inM)\n    );\n''',
}

def strip_comment(line):
    """去掉 // 行尾注释（端口声明里没有字符串字面量，够用）。"""
    i = line.find('//')
    return line[:i] if i >= 0 else line


def module_header_end(lines, start):
    """返回模块头（含端口列表 ');'）结束的行号。支持 #(参数) 与普通端口。"""
    depth = 0
    i = start
    while i < len(lines):
        body = strip_comment(lines[i])
        for ch in body:
            if ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
        if depth == 0 and ';' in body:
            return i
        i += 1
    raise ValueError('module header not terminated')


def gen_one(src, dst):
    with open(src, encoding='utf-8') as f:
        lines = f.readlines()

    mod_idx = next(i for i, l in enumerate(lines)
                   if re.match(r'\s*module\s+', l))
    end_idx = module_header_end(lines, mod_idx)
    header = ''.join(lines[:end_idx + 1])

    m = re.search(r'module\s+(\w+)', header)
    name = m.group(1) if m else os.path.basename(src)

    parts = [header.rstrip('\n')]
    if name in SKELETONS:
        parts.append('\n' + SKELETONS[name])
    todo = TODO_06 if os.path.basename(os.path.dirname(dst)) == '06' else TODO
    parts.append('\n' + todo + '\nendmodule\n')

    os.makedirs(os.path.dirname(dst), exist_ok=True)
    with open(dst, 'w', encoding='utf-8') as f:
        f.write(''.join(parts))
    print('generated %s' % dst)


def main():
    targets = sys.argv[1:] or [d for d in sorted(os.listdir(SOL))
                               if os.path.isdir(os.path.join(SOL, d))]
    # Project 07（posedge Hack）是给 NPU 用的已知库，不生成作业模板
    targets = [t for t in targets if t != '07']
    for proj in targets:
        src_dir = os.path.join(SOL, proj)
        if not os.path.isdir(src_dir):
            print('skip: %s' % src_dir)
            continue
        for fn in sorted(os.listdir(src_dir)):
            if fn.endswith('.v'):
                gen_one(os.path.join(src_dir, fn),
                        os.path.join(ASG, proj, fn))


if __name__ == '__main__':
    main()
