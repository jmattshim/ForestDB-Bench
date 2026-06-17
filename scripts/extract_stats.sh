#!/bin/bash

FILE=$1
OUTPUT="summary.txt"

echo "" >> $OUTPUT
echo $FILE >> $OUTPUT

echo "Compaction breakdown" >> $OUTPUT
# file info, SLMCPY, EXEC, NVMCPY, read meta, apply, TOTAL
cat ycsb_logs/$FILE | ./breakdown_compaction.py >> $OUTPUT

echo "Read breakdown" >> $OUTPUT
# meta, init, alloc&free, load, exec, output, TOTAL, levels, hit level
cat ycsb_logs/$FILE | ./breakdown_read.py >> $OUTPUT

echo "CDF read" >> $OUTPUT
# p50, p75, p90, p95, p99
cat ycsb_logs/$FILE | ./cdf_read_latency.py >> $OUTPUT

echo "CDF write" >> $OUTPUT
# p50, p75, p90, p95, p99
cat ycsb_logs/$FILE | ./cdf_write_latency.py >> $OUTPUT

