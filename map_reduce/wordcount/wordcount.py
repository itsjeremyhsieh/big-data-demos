import string
import sys
import time
from pathlib import Path

# INPUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parent / "sample_input.txt"
INPUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parent / "large_input.txt"

# Step 1: Map
start = time.time()
pairs = []
with open(INPUT) as f:
    for line in f:
        for word in line.lower().split():
            word = word.strip(string.punctuation)
            if word:
                pairs.append((word, 1))

# Step 2: Shuffle & Sort
pairs.sort()

# Step 3: Reduce
counts = {}
for word, n in pairs:
    counts[word] = counts.get(word, 0) + n

# Print 
print("Word Count Results\n")
print(f"{'Word':<15} Count")
print("-" * 22)

for word, count in sorted(counts.items(), key=lambda item: (-item[1], item[0])):
    print(f"{word:<15} {count:>5}")

file_mb = INPUT.stat().st_size / (1024 * 1024)
elapsed = time.time() - start

print()
print(f"File size:     {file_mb:.1f} MB")
print(f"Total words:   {len(pairs):,}")
print(f"Unique words:  {len(counts):,}")
print(f"Time:          {elapsed:.1f} seconds")

