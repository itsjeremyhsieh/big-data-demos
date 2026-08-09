import sys

counts = {}
for line in sys.stdin:
    word, n = line.split()
    counts[word] = counts.get(word, 0) + int(n)

print("Word Count Results\n")
print(f"{'Word':<15} Count")
print("-" * 22)

for word, count in sorted(counts.items(), key=lambda item: (-item[1], item[0])):
    print(f"{word:<15} {count:>5}")
