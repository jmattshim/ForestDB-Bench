#!/usr/bin/env python3
import sys
import re

latencies = []

for line in sys.stdin:
    if "[stat]" not in line:
        continue

    match = re.search(r'\[stat\] Put: (\d+)', line)
    if match:
        latencies.append(int(match.group(1)))

if not latencies:
    print("No latency data found.")
    sys.exit(1)

latencies.sort()
n = len(latencies)

def percentile(sorted_data, p):
    idx = p / 100 * len(sorted_data)
    if idx == int(idx):
        idx = int(idx) - 1
    else:
        idx = int(idx)
    idx = max(0, min(idx, len(sorted_data) - 1))
    return sorted_data[idx]

print(f"Total samples: {n}")
results = [
    percentile(latencies, 50),
    percentile(latencies, 75),
    percentile(latencies, 90),
    percentile(latencies, 95),
    percentile(latencies, 99),
]
print(",".join(str(x) for x in results))
#print("\n".join(str(x) for x in results))
