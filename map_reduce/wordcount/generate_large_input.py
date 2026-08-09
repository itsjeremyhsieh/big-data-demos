from pathlib import Path

OUTPUT = Path(__file__).parent / "large_input.txt"
TARGET_MB = 100

TEXT = """\
MapReduce is a programming model for processing large datasets.
MapReduce jobs split work into map and reduce phases.
In word count, the map phase emits one for each word.
The reduce phase sums counts for each unique word.
MapReduce makes it easy to scale word count across many machines.
Big data grows faster than a single computer can store in memory.
Distributed systems split the work across many nodes instead.
"""


def generate(output_path: Path = OUTPUT, target_mb: int = TARGET_MB) -> None:
    target_bytes = target_mb * 1024 * 1024
    block = TEXT.encode("utf-8")

    print(f"Generating {target_mb} MB file: {output_path.name}")

    with output_path.open("wb") as f:
        written = 0
        while written < target_bytes:
            f.write(block)
            written += len(block)

    size_mb = output_path.stat().st_size / (1024 * 1024)
    print(f"Done. File size: {size_mb:.1f} MB")


if __name__ == "__main__":
    generate()
