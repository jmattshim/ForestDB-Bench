#!/usr/bin/env python3
from sys import argv, stdin, stdout, stderr
import re

def main():
    total = 0
    stat_sum = [0, 0, 0, 0, 0, 0, 0];

    for line in stdin:
        line = line.rstrip()
        if "[CSD-breakdown]" not in line:
            continue
        line = re.split(r'[\],:]', line)
        tmp_line = line[7]
        tmp_line = re.split('[ ]', tmp_line)
        total = total + 1
        stat_sum[0] = stat_sum[0] + int(tmp_line[1])
        stat_sum[1] = stat_sum[1] + int(tmp_line[2])
        stat_sum[2] = stat_sum[2] + int(tmp_line[3])
        stat_sum[3] = stat_sum[3] + int(tmp_line[4])
        stat_sum[4] = stat_sum[4] + int(tmp_line[5])
        stat_sum[5] = stat_sum[5] + int(tmp_line[6])
        if len(tmp_line) > 7:
            stat_sum[6] = stat_sum[6] + int(tmp_line[7])

    if stat_sum[6] != 0:
        print("%.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f" % (stat_sum[1]/total, stat_sum[2]/total, stat_sum[3]/total, stat_sum[4]/total, stat_sum[5]/total, stat_sum[6]/total, stat_sum[0]/total), file=stdout)
    else:
        print("%.2f, %.2f, %.2f, %.2f, %.2f, %.2f" % (stat_sum[1]/total, stat_sum[2]/total, stat_sum[3]/total, stat_sum[4]/total, stat_sum[5]/total, stat_sum[0]/total), file=stdout)
main()
