#!/usr/bin/env bash
# Run Spark word count on a real Spark cluster in Docker.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if ! command -v docker >/dev/null; then
  echo "Docker is required for this demo."
  exit 1
fi

INPUT="${1:-wordcount/sample_input.txt}"
WORKERS="${2:-1}"
INPUT_NAME="$(basename "$INPUT")"

if ! [[ "$WORKERS" =~ ^[1-9][0-9]*$ ]]; then
  echo "Worker count must be a positive integer. Got: $WORKERS"
  exit 1
fi

if [[ ! -f "$ROOT/$INPUT" ]]; then
  echo "Input file not found: $ROOT/$INPUT"
  exit 1
fi

echo "Starting Spark cluster..."
docker compose up -d --scale spark-worker="$WORKERS"

echo "Waiting for Spark master to be ready..."
for i in $(seq 1 60); do
  if docker compose exec -T spark-master bash -lc "</dev/tcp/127.0.0.1/7077" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "Running Spark word count job..."
docker compose exec -T spark-master /opt/spark/bin/spark-submit \
  --master spark://spark-master:7077 \
  /opt/spark-demo/wordcount.py \
  "/opt/spark-demo/$INPUT_NAME"

echo
echo "Spark UI: http://localhost:8081"
echo "Spark workers: $WORKERS"
