import string
import sys

for line in sys.stdin:
    for word in line.lower().split():
        word = word.strip(string.punctuation)
        if word:
            print(f"{word}\t1")
