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

echo "Starting Hadoop cluster..."
docker compose up -d --scale nodemanager="$WORKERS"

NAMENODE_CONTAINER_ID="$(docker compose ps -q namenode)"
RESOURCEMANAGER_CONTAINER_ID="$(docker compose ps -q resourcemanager)"

if [[ -z "$NAMENODE_CONTAINER_ID" ]]; then
  echo "Could not find namenode container after startup."
  exit 1
fi

if [[ -z "$RESOURCEMANAGER_CONTAINER_ID" ]]; then
  echo "Could not find resourcemanager container after startup."
  exit 1
fi

echo "Waiting for Hadoop to be ready..."
sleep 20

echo "Waiting for HDFS to leave safe mode..."
docker exec "$NAMENODE_CONTAINER_ID" bash -c '
  for i in $(seq 1 60); do
    if hdfs dfsadmin -safemode get 2>/dev/null | grep -q "Safe mode is OFF"; then
      exit 0
    fi
    sleep 2
  done
  echo "HDFS is still in safe mode after waiting." >&2
  exit 1
'

if [[ "$(docker inspect -f '{{.State.Running}}' "$RESOURCEMANAGER_CONTAINER_ID" 2>/dev/null || true)" != "true" ]]; then
  echo "ResourceManager exited during startup, restarting it now that HDFS is ready..."
  docker compose up -d resourcemanager
  RESOURCEMANAGER_CONTAINER_ID="$(docker compose ps -q resourcemanager)"
fi

echo "Waiting for ResourceManager to be running..."
for i in $(seq 1 60); do
  if [[ "$(docker inspect -f '{{.State.Running}}' "$RESOURCEMANAGER_CONTAINER_ID" 2>/dev/null || true)" == "true" ]]; then
    break
  fi
  sleep 2
done

if [[ "$(docker inspect -f '{{.State.Running}}' "$RESOURCEMANAGER_CONTAINER_ID" 2>/dev/null || true)" != "true" ]]; then
  echo "ResourceManager container is not running after waiting." >&2
  exit 1
fi

echo "Waiting for ResourceManager DNS and RPC readiness..."
docker exec "$NAMENODE_CONTAINER_ID" bash -c '
  for i in $(seq 1 60); do
    if bash -c "</dev/tcp/resourcemanager/8032" >/dev/null 2>&1; then
      exit 0
    fi
    sleep 2
  done
  echo "ResourceManager is not reachable from namenode (DNS/RPC not ready)." >&2
  exit 1
'

echo "Copying input and scripts to namenode..."
docker cp "$ROOT/$INPUT" "$NAMENODE_CONTAINER_ID":/tmp/"$INPUT_NAME"

echo "Preparing portable mapper/reducer scripts inside namenode..."
docker exec -i "$NAMENODE_CONTAINER_ID" bash <<'EOF'
cat >/tmp/mapper.sh <<'MAP'
#!/usr/bin/env sh
tr -cs '[:alnum:]' '\n' | tr '[:upper:]' '[:lower:]' | sed '/^$/d' | awk '{print $1"\t1"}'
MAP
chmod +x /tmp/mapper.sh

cat >/tmp/reducer.sh <<'RED'
#!/usr/bin/env sh
awk -F '\t' '
NR==1 { word=$1; count=$2; next }
$1==word { count+=$2; next }
{ print word "\t" count; word=$1; count=$2 }
END { if (NR>0) print word "\t" count }
'
RED
chmod +x /tmp/reducer.sh
EOF

echo "Running Hadoop Streaming job..."
docker exec "$NAMENODE_CONTAINER_ID" bash -c "
  hdfs dfs -mkdir -p /input &&
  hdfs dfs -put -f /tmp/$INPUT_NAME /input/$INPUT_NAME &&
  hdfs dfs -rm -r -f /output &&
  yarn jar /opt/hadoop-3.2.1/share/hadoop/tools/lib/hadoop-streaming-3.2.1.jar \
    -input /input/$INPUT_NAME \
    -output /output \
    -mapper 'sh mapper.sh' \
    -reducer 'sh reducer.sh' \
    -file /tmp/mapper.sh \
    -file /tmp/reducer.sh &&
  echo &&
  echo 'Word Count Results' &&
  echo &&
  hdfs dfs -cat /output/part-*
"

echo
echo "Hadoop UI: http://localhost:9870 (HDFS)  http://localhost:8088 (YARN)"
echo "NodeManager workers: $WORKERS"
