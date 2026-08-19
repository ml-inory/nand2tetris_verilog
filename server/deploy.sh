#!/usr/bin/env bash
# 云端一键更新 n2t-judge 容器（在腾讯云服务器上运行）。
#
# 用法：
#   ssh -i ~/tencent_cloud.pem ubuntu@43.153.202.142 'bash -s' < server/deploy.sh
#
# 说明：
#   - 从 GHCR 拉取最新镜像（推送到 main 后由 GitHub Actions 自动构建）；
#   - 保留 /opt/n2t-data 数据卷（用户/提交历史）；
#   - 容器以非 root judge 用户运行，带 tmpfs/pids/memory/cap-drop 限制。
set -euo pipefail

IMAGE="${IMAGE:-ghcr.io/ml-inory/nand2tetris_verilog:latest}"
NAME="${NAME:-n2t-judge}"
DATA_DIR="${DATA_DIR:-/opt/n2t-data}"

echo "==> Pulling $IMAGE"
docker pull "$IMAGE"

echo "==> Preparing data dir $DATA_DIR"
sudo mkdir -p "$DATA_DIR"
sudo chown 10001:10001 "$DATA_DIR"

echo "==> Replacing container $NAME"
docker stop "$NAME" || true
docker rm "$NAME" || true

docker run -d \
  --name "$NAME" \
  -p 127.0.0.1:8000:8000 \
  -v "$DATA_DIR:/srv/app/server/data" \
  --tmpfs /tmp:size=64m \
  --pids-limit 64 \
  --memory 1g \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --restart unless-stopped \
  "$IMAGE"

echo "==> Verifying"
sleep 3
docker ps --filter "name=$NAME" --format '{{.Names}} {{.Status}} {{.Image}}'
curl -s -o /dev/null -w 'local_api:%{http_code}\n' http://127.0.0.1:8000/api/problems
echo "Done."
