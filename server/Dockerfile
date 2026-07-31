# nand2tetris Verilog 在线判题 — 生产镜像
# 构建：  docker build -f server/Dockerfile -t n2t-server .
# 运行：  docker run --rm -p 8000:8000 --tmpfs /tmp:size=64m n2t-server
#         建议再加 --pids-limit 64 --memory 1g --cap-drop ALL --security-opt no-new-privileges
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends iverilog \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    IVERILOG=iverilog \
    VVP=vvp

WORKDIR /srv/app

# 先装依赖（利用构建缓存）
COPY server/requirements.txt server/requirements.txt
RUN pip install --no-cache-dir -r server/requirements.txt

# 拷贝判题所需：题库/判题代码、solution 依赖、tb、programs、web 前端
COPY server /srv/app/server
COPY solution /srv/app/solution
COPY tb /srv/app/tb
COPY programs /srv/app/programs

# 非 root 运行（判题的是不可信代码，容器内无权限、无密钥）
RUN useradd -m -u 10001 judge && chown -R judge:judge /srv/app
USER judge
WORKDIR /srv/app/server

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
