"""Generate a large input file for Spark word count demos."""

import sys
from pathlib import Path

OUT = Path(__file__).parent / "large_input.txt"

BASE_LINES = [
    "spark enables fast distributed data processing",
    "word count is a classic map reduce style example",
    "spark can process large data across partitions",
    "resilient distributed datasets power parallel workloads",
]


def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: python generate_data.py <size_mb>")
        print("Example: python generate_data.py 300")
        sys.exit(1)

    try:
        target_mb = float(sys.argv[1])
    except ValueError:
        print("Size must be a number.")
        sys.exit(1)

    if target_mb <= 0:
        print("Size must be greater than 0.")
        sys.exit(1)

    target_bytes = int(target_mb * 1024 * 1024)

    current_size = 0
    line_index = 0

    with OUT.open("w", encoding="utf-8") as f:
        while current_size < target_bytes:
            line = BASE_LINES[line_index % len(BASE_LINES)] + "\n"
            f.write(line)

            current_size += len(line.encode("utf-8"))
            line_index += 1

    actual_size_mb = OUT.stat().st_size / (1024 * 1024)

    print(f"Generated: {OUT}")
    print(f"Target size: {target_mb:.1f} MB")
    print(f"Actual size: {actual_size_mb:.1f} MB")
    print(f"Size: {OUT.stat().st_size:,} bytes")


if __name__ == "__main__":
    main()