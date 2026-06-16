#!/usr/bin/env python3
import sys
import re

# Storage for sums and counts
csd_field_sums = []
csd_count = 0
host_field_sums = []
host_count = 0

# Read from stdin
for line in sys.stdin:
	tmp = line.rstrip()
	if "[stat]" not in tmp:
		continue

	# Match lines like: [stat] CSD read: 3 12 73 82 15 464 741, 3, 4
	csd_match = re.search(r'\[stat\] CSD read: (.+)', line)
	host_match = re.search(r'\[stat\] Host read: (.+)', line)

	if csd_match:
		# Extract the numbers part
		numbers_str = csd_match.group(1)
		# Split by spaces and commas, filter empty strings
		numbers = [int(x.strip()) for x in re.split(r'[,\s]+', numbers_str) if x.strip()]

		# Extend our storage to accommodate all fields
		while len(csd_field_sums) < len(numbers):
			csd_field_sums.append(0)

		# Add each number to its corresponding field sum
		for i, num in enumerate(numbers):
			csd_field_sums[i] += num

		csd_count += 1

	elif host_match:
		# Extract the numbers part
		numbers_str = host_match.group(1)
		# Split by spaces and commas, filter empty strings
		numbers = [int(x.strip()) for x in re.split(r'[,\s]+', numbers_str) if x.strip()]

		# Extend our storage to accommodate all fields
		while len(host_field_sums) < len(numbers):
			host_field_sums.append(0)

		# Add each number to its corresponding field sum
		for i, num in enumerate(numbers):
			host_field_sums[i] += num

		host_count += 1

# Calculate and print combined average of CSD and host reads
print()
total_count = csd_count + host_count
if total_count > 0:
	num_fields = max(len(csd_field_sums), len(host_field_sums))
	averages = []
	for i in range(num_fields):
		csd_val = csd_field_sums[i] if i < len(csd_field_sums) else 0
		host_val = host_field_sums[i] if i < len(host_field_sums) else 0
		avg = (csd_val + host_val) / total_count
		averages.append(f"{avg:.2f}")

	print(", ".join(averages))
