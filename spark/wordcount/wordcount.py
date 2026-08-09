import re
import sys
from pathlib import Path
from typing import List, Optional

from pyspark.sql import SparkSession

DIR = Path(__file__).parent
DEFAULT_INPUT = DIR / "sample_input.txt"


def tokenize(line: str) -> List[str]:
    return [w.lower() for w in re.split(r"[^A-Za-z0-9]+", line) if w]


def resolve_input_path(arg: Optional[str]) -> Path:
    if not arg:
        return DEFAULT_INPUT

    candidate = Path(arg)
    if candidate.is_file():
        return candidate

    local_candidate = DIR / arg
    if local_candidate.is_file():
        return local_candidate

    raise FileNotFoundError(f"Input file not found: {arg}")


def main() -> None:
    arg = sys.argv[1] if len(sys.argv) > 1 else None
    input_path = resolve_input_path(arg)

    spark = SparkSession.builder.appName("SparkWordCountDemo").getOrCreate()

    sc = spark.sparkContext
    lines = sc.textFile(str(input_path))

    counts = (
        lines.flatMap(tokenize)
        .map(lambda word: (word, 1))
        .reduceByKey(lambda a, b: a + b)
        .sortByKey()
    )

    results = counts.collect()

    print(f"Spark word count on: {input_path}")
    print(f"Total unique words: {len(results)}\n")
    for word, count in results:
        print(f"{word}\t{count}")

    spark.stop()


if __name__ == "__main__":
    main()
