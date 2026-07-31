# nand2tetris Verilog 在线判题站（server 分支）

把仓库里的 32 道 Verilog 作业发布成类似 HDLBits 的在线练习：浏览器里写代码，
服务端用 Icarus Verilog 跑官方 testbench，实时返回 PASS/FAIL 与不匹配行。

## 架构

```
浏览器(Monaco 编辑器)
   │  /api/problems  /api/problems/{id}  /api/submit
   ▼
FastAPI (server/app/main.py)
   │
   ├─ problems.json         题库（server/gen_problems.py 生成）
   └─ judge.py              判题核心
        ├─ 学生代码 user.v
        ├─ 依赖模块（solution/ 按例化关系 BFS 收集，跳过本题自身）
        ├─ 官方 testbench tb/0X/<chip>_tb.v
        └─ iverilog -g2012 → vvp → 解析 PASS/FAIL
```

- 题库不包含答案：判题时**不编译** solution 里本题自己的文件，只编译学生提交 + 依赖模块 + 测试台。
- 依赖自动收集：`gen_problems.py` 从 solution 解析模块例化关系（如 ALU → Add16/Mux16/...）。
- Computer 三题共用 `n2t_computer`，运行期自动拷贝 `programs/*.hack`。

## 本地运行

```bash
# 1. 生成题库（改过 solution/assignment/tb 后需重跑）
python3 server/gen_problems.py

# 2. 安装依赖
python3 -m venv server/.venv
server/.venv/bin/pip install -r server/requirements.txt

# 3. 启动（需要 iverilog 在 PATH；无系统包可用仓库里的 iverilog_*.deb）
export PATH=/tmp/iverilog-local/usr/bin:$PATH
server/.venv/bin/uvicorn app.main:app --port 8000   # 在 server/ 目录下
```

打开 http://localhost:8000 。

## Docker 部署

```bash
docker build -f server/Dockerfile -t n2t-server .
docker run --rm -d -p 8000:8000 \
  --tmpfs /tmp:size=64m --pids-limit 64 --memory 1g \
  --cap-drop ALL --security-opt no-new-privileges n2t-server
# 或
cd server && docker compose up -d
```

容器内以非 root 用户 `judge` 运行，判题进程还有 CPU/内存/文件大小 rlimit 与超时 kill。
生产环境建议再套一层反向代理（nginx/caddy）做 HTTPS。

## 安全边界（重要）

- 判题执行的是**不可信 Verilog**，务必保持：非 root、无网络外联权限（如 iptables 或独立
  network namespace 阻止容器 egress）、`--pids-limit`、`--memory`、`--tmpfs`、`cap_drop ALL`。
- 当前无用户系统：任何人可提交、无提交历史/排行榜。要防刷可加简单 token 或限流（见下）。
- 判题每次在独立临时目录运行，进程组超时强杀，理论上一个请求最多占用约 30s CPU。

## API

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | /api/problems | 题目列表 |
| GET | /api/problems/{id} | 单题详情（端口/说明/初始代码） |
| POST | /api/submit | `{id, code}` → `{status: pass\|fail\|error, summary, log, compile}` |

## 题库更新

```bash
make assign          # 从 solution 重新生成 assignment（tools/gen_assignment.py）
make tb              # 重新生成 testbench（tools/tst2tb.py）
python3 server/gen_problems.py   # 重新生成题库 JSON
```

## 已知限制 / 后续可做

- 未做波形可视化（可加 VCD → WaveDrom）。
- 未做用户/进度持久化（前端仅用 localStorage 记忆代码）。
- 判题并发默认不限，可加 `--limit-concurrency` 或队列。
