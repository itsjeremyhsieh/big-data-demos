"""Generate a larger input file for Spark word count demos."""

from pathlib import Path

OUT = Path(__file__).parent / "large_input.txt"
BASE_LINES = [
    "spark enables fast distributed data processing",
    "word count is a classic map reduce style example",
    "spark can process large data across partitions",
    "resilient distributed datasets power parallel workloads",
]
REPEAT = 300000


def main() -> None:
    with OUT.open("w", encoding="utf-8") as f:
        for i in range(REPEAT):
            f.write(BASE_LINES[i % len(BASE_LINES)] + "\n")
    size_mb = OUT.stat().st_size / (1024 * 1024)
    print(f"Generated {OUT} ({size_mb:.1f} MB)")


if __name__ == "__main__":
    main()
