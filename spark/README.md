# Spark Word Count Demo

A simple word count example using **PySpark**.

## Run on Spark in Docker

```bash
bash spark/run_docker.sh
```

Set worker count:

```bash
bash spark/run_docker.sh wordcount/sample_input.txt 3
```

Use a custom input file:

```bash
bash spark/run_docker.sh wordcount/large_input.txt 2
```

Stop the cluster:

```bash
cd spark && docker compose down
```

Web UI:
- Spark Master UI: http://localhost:8081

## Files

```
spark/
├── docker-compose.yml
├── run_docker.sh
├── README.md
└── wordcount/
    ├── wordcount.py
    ├── generate_large_input.py
    └── sample_input.txt
```

## How it works

1. **Read** text into Spark RDD partitions.
2. **Map** each token to `(word, 1)`.
3. **Reduce** by key to sum counts.
4. **Collect** and print sorted results.
