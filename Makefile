# nand2tetris_verilog —— Verilog 版 nand2tetris Hardware 作业
#
# 目录说明：
#   solution/    完整答案
#   assignment/  学生作业模板（实现留空，待补全）
#
# 常用命令：
#   make test                用 solution 全量回归（答案验证）
#   make sim-01              验证作业 Project 1（默认用 assignment，学生模式）
#   make sim-02              验证作业 Project 2（算术 / ALU）
#   make sim-03              验证作业 Project 3（时序电路）
#   make sim-05              验证作业 Project 5（CPU / Computer）
#   make sim-02 RTLDIR=solution   用答案目录仿真（对照/调试）
#   make wave CHIP=ALU       用作业目录生成波形（需要 gtkwave）
#   make tb                  重新生成全部 testbench（tools/tst2tb.py）
#   make assign              从 solution 重新生成 assignment（tools/gen_assignment.py）
#   make clean               清理 sim/ 输出

IVERILOG ?= iverilog
VVP      ?= vvp
PYTHON   ?= python3
PDF_PY   ?= python3

# 默认用学生作业目录；答案回归用 RTLDIR=solution
RTLDIR  ?= assignment
SOLRTL  := solution
RTL := $(wildcard $(RTLDIR)/0*/*.v)
SIMDIR := sim

.PHONY: all test tb assign sim-01 sim-02 sim-03 sim-05 sim-06 sim-07 wave pdf-npu clean

all: test

tb:
	$(PYTHON) tools/tst2tb.py

assign:
	$(PYTHON) tools/gen_assignment.py

pdf-npu:
	$(PDF_PY) tools/gen_npu_pdfs.py

sim-01 sim-02 sim-03 sim-05 sim-06 sim-07: sim-%: tb
	@mkdir -p $(SIMDIR)
	@echo "RTLDIR = $(RTLDIR)"
	@fail=0; \
	for tb in tb/$*/*_tb.v; do \
		mod=$$(basename $$tb .v); \
		echo "== $$mod =="; \
		if $(IVERILOG) -g2012 -s $$mod -o $(SIMDIR)/$$mod.vvp $(RTL) $$tb && \
		   $(VVP) $(SIMDIR)/$$mod.vvp | grep -E 'PASS|FAIL'; then \
			:; \
		else \
			fail=1; \
		fi; \
	done; \
	if [ $$fail -ne 0 ]; then echo "!!! Project $* has failures"; exit 1; fi

test:
	$(MAKE) sim-01 sim-02 sim-03 sim-05 sim-06 sim-07 RTLDIR=$(SOLRTL)
	@echo "All projects simulated (solution)."

wave: tb
	@mkdir -p $(SIMDIR)
	@test -n "$(CHIP)" || (echo "usage: make wave CHIP=ALU"; exit 1)
	@test -f tb/0*/$(CHIP)_tb.v || (echo "no testbench for $(CHIP)"; exit 1)
	$(IVERILOG) -g2012 -DDUMP_VCD -s $(CHIP)_tb -o $(SIMDIR)/$(CHIP)_tb.vvp $(RTL) tb/0*/$(CHIP)_tb.v
	$(VVP) $(SIMDIR)/$(CHIP)_tb.vvp
	@if command -v gtkwave >/dev/null 2>&1; then \
		gtkwave $(SIMDIR)/$(CHIP)_tb.vcd; \
	else \
		echo "gtkwave not found; open sim/$(CHIP)_tb.vcd manually"; \
	fi

clean:
	rm -rf $(SIMDIR)
