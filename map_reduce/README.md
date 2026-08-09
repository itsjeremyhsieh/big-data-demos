# MapReduce Word Count

A simple word count example that shows the 3 MapReduce steps.

## Files

- `wordcount/wordcount.py` — all 3 steps in one file (start here)
- `wordcount/mapper.py` / `reducer.py` — same idea, split into 2 scripts
- `wordcount/sample_input.txt` — small sample text
- `wordcount/generate_large_input.py` — creates a 500 MB file for demos

## Run on small data

```bash
cd map_reduce/wordcount
python wordcount.py
```

## Demo: why a single node fails on big data

This version keeps **every word in memory** before sorting. That works for small files, but breaks down on large data.

1. Generate a large input file (~500 MB):

```bash
python generate_large_input.py
```

2. Run word count on it:

```bash
python wordcount.py large_input.txt
```

You should see high memory use, slow runtime, and possibly an out-of-memory crash on smaller machines. Real MapReduce avoids this by processing data in chunks across many machines instead of loading everything at once.

## Optional: Unix pipeline

```bash
cat sample_input.txt | python mapper.py | sort | python reducer.py
```
