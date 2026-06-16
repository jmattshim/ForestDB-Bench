#!/bin/bash

FILE=$1
OUTPUT="summary.txt"

echo "" >> $OUTPUT
echo $FILE >> $OUTPUT

echo "" >> $OUTPUT
cat ycsb_logs/$FILE | ./make_average_from_log.sh >> $OUTPUT

echo "" >> $OUTPUT
cat ycsb_logs/$FILE | ./breakdown_compaction.py >> $OUTPUT

echo "" >> $OUTPUT
cat ycsb_logs/$FILE | ./breakdown_read.py >> $OUTPUT

echo "" >> $OUTPUT
cat ycsb_logs/$FILE | ./cdf_read_latency.py >> $OUTPUT

echo "" >> $OUTPUT
cat ycsb_logs/$FILE | ./cdf_write_latency.py >> $OUTPUT

