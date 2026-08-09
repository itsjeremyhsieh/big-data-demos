# Hadoop Word Count Demo

A simple Hadoop MapReduce word count using **Hadoop Streaming** (mapper + reducer scripts).

## Setup

```bash
bash hadoop/setup.sh
source .venv/bin/activate
```

## Option 1: Run locally (no cluster needed)

Simulates Hadoop by splitting the file into map tasks and running them in parallel:

```bash
bash hadoop/run.sh
```

## Option 2: Run on real Hadoop in Docker

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
├── setup.sh              # create venv
├── run.sh                # local parallel demo
├── run_docker.sh         # real Hadoop in Docker
├── docker-compose.yml    # Hadoop cluster
├── config/hadoop.env     # cluster config
└── wordcount/
    ├── run_local.py      # local runner
    ├── mapper.py         # map: emit (word, 1)
    ├── reducer.py        # reduce: sum counts
    └── sample_input.txt
```

## How it works

1. **Map** — each chunk of input is processed by `mapper.py`, emitting `word\t1`
2. **Shuffle/Sort** — Hadoop groups the same words together
3. **Reduce** — `reducer.py` sums counts per word

This is the same pattern used in production Hadoop jobs.
