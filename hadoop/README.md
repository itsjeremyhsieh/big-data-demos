# Hadoop Word Count Demo

A simple Hadoop MapReduce word count using **Hadoop Streaming** (mapper + reducer scripts).

## Run on Hadoop in Docker

Starts a 4-node Hadoop cluster (HDFS + YARN) and submits a Streaming job:

```bash
bash hadoop/run_docker.sh
```

Set worker count (NodeManagers):

```bash
bash hadoop/run_docker.sh hadoop/wordcount/sample_input.txt 3
```

Web UIs:
- HDFS: http://localhost:9870
- YARN: http://localhost:8088

Stop the cluster:

```bash
cd hadoop && docker compose down
```

## Files

```
hadoop/
├── run_docker.sh         # real Hadoop in Docker
├── docker-compose.yml    # Hadoop cluster
├── config/hadoop.env     # cluster config
└── wordcount/
    └── sample_input.txt
```

## How it works

1. **Prepare** input and helper scripts inside the NameNode container.
2. **Map** — Hadoop Streaming emits `word\t1` from the portable mapper.
3. **Shuffle/Sort** — Hadoop groups the same words together.
4. **Reduce** — Hadoop Streaming sums counts per word.

This is the same pattern used in production Hadoop jobs.
