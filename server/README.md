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
# 数据卷 /opt/n2t-data 用于持久化 SQLite（用户/会话/提交历史）
sudo mkdir -p /opt/n2t-data && sudo chown 10001:10001 /opt/n2t-data
docker run --rm -d -p 8000:8000 \
  -v /opt/n2t-data:/srv/app/server/data \
  --tmpfs /tmp:size=64m --pids-limit 64 --memory 1g \
  --cap-drop ALL --security-opt no-new-privileges n2t-server
# 或
cd server && docker compose up -d
```

容器内以非 root 用户 `judge` 运行，判题进程还有 CPU/内存/文件大小 rlimit 与超时 kill。
生产环境建议再套一层反向代理（nginx/caddy）做 HTTPS。

### 云端部署（GitHub Container Registry）

推送到 `main` 后，GitHub Actions 会自动构建镜像并发布到 GHCR：

```bash
docker pull ghcr.io/ml-inory/nand2tetris_verilog:latest
sudo mkdir -p /opt/n2t-data && sudo chown 10001:10001 /opt/n2t-data
docker run --rm -d -p 8000:8000 \
  -v /opt/n2t-data:/srv/app/server/data \
  --tmpfs /tmp:size=64m --pids-limit 64 --memory 1g \
  --cap-drop ALL --security-opt no-new-privileges \
  ghcr.io/ml-inory/nand2tetris_verilog:latest
```

题库已包含 Project 06（PE / SystolicArray）与 Project 07
（RAM16K_Posedge / CPU_Posedge / Memory_Posedge / ComputerPosedge）。

## 安全边界（重要）

- 判题执行的是**不可信 Verilog**，务必保持：非 root、无网络外联权限（如 iptables 或独立
  network namespace 阻止容器 egress）、`--pids-limit`、`--memory`、`--tmpfs`、`cap_drop ALL`。
- 当前无用户系统：任何人可提交、无提交历史/排行榜。要防刷可加简单 token 或限流（见下）。
- 判题每次在独立临时目录运行，进程组超时强杀，理论上一个请求最多占用约 30s CPU。

## API

| 方法 | 路径 | 说明 |
|---|---|---|
| POST | /api/register | 注册 `{username, password}` → `{token, username}` |
| POST | /api/login | 登录 → `{token, username}` |
| POST | /api/logout | 退出（Bearer token） |
| GET | /api/me | 当前用户 |
| GET | /api/problems | 题目列表 |
| GET | /api/problems/{id} | 单题详情（端口/说明/初始代码） |
| GET | /api/problems/{id}/tb | 官方 testbench 原文（前端“查看测试台”） |
| POST | /api/submit | 判题（需登录）→ `{status, summary, log, compile, wave}` |
| GET | /api/submissions | 我的提交历史（含每次结果摘要） |
| GET | /api/submissions/{id} | 某次提交详情（代码 + 完整结果，可回看波形） |
| GET | /api/recent | 全局最近判题（内存，匿名） |

## 用户与提交历史

- 注册/登录：用户名 3-24 位（字母/数字/下划线），密码至少 6 位；
  密码 PBKDF2-HMAC-SHA256 加盐哈希，会话 token 存 SQLite，30 天有效。
- 提交历史：每次判题记录（代码 + 结果含波形）写入 `server/data/judge.db`，
  登录后在侧栏“我的提交”查看，点击可载入该次代码与结果回看。
- 数据持久化：Docker 部署需挂载数据卷（见下），否则重启容器历史丢失。

## 进阶功能

- **波形可视化**：判题通过/未通过都会附带 `wave`（WaveDrom JSON，只含端口信号）。
  前端用仓库内 vendored 的 WaveDrom（`server/web/vendor/`，MIT）本地渲染，无需外部 CDN。
- **进度统计**：题目列表显示 `已完成 X/32`，通过的题目标 ✓（localStorage，本机记录）。
- **测试台查看**：每题可查看官方 testbench 原文，了解测试向量与期望。
- **最近判题**：侧栏显示最近 10 条判题结果（服务端内存，重启清空）。
- **提交限流**：每 IP 每 60s 最多 `SUBMIT_LIMIT` 次（默认 60，环境变量可调，超限返回 429）。

## 题库更新

## 题库更新

```bash
make assign          # 从 solution 重新生成 assignment（tools/gen_assignment.py）
make tb              # 重新生成 testbench（tools/tst2tb.py）
python3 server/gen_wave.py      # 重新生成波形演示激励（server/wave_tb/）
python3 server/gen_problems.py  # 重新生成题库 JSON（含 wave_tb 路径）
```

## 已知限制 / 后续可做

- 无账号体系：进度在 localStorage、最近判题在服务端内存，换浏览器/重启即丢失；
  要做排行榜/提交历史需加用户系统与数据库。
- 判题为同步执行，高并发时建议加队列或 `--limit-concurrency`。
- 波形为“演示激励”（官方 .tst 开头若干步），不是完整回归波形。
