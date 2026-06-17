#!/bin/bash

sudo chmod o+w /sys/fs/cgroup/cgroup.procs

# Recreate
sudo rmdir /sys/fs/cgroup/flax.slice
sudo mkdir /sys/fs/cgroup/flax.slice

sudo chmod o+w /sys/fs/cgroup/flax.slice/cgroup.procs
echo +cpuset +memory +cpu	| sudo tee /sys/fs/cgroup/cgroup.subtree_control

#echo 400000 100000			| sudo tee /sys/fs/cgroup/flax.slice/cpu.max         >/dev/null
#echo 1,5,9,13				| sudo tee /sys/fs/cgroup/flax.slice/cpuset.cpus     >/dev/null

#echo 800000 100000			| sudo tee /sys/fs/cgroup/flax.slice/cpu.max         >/dev/null
#echo 1,5,9,13,17,21,25,29	| sudo tee /sys/fs/cgroup/flax.slice/cpuset.cpus     >/dev/null

echo 1600000 100000			| sudo tee /sys/fs/cgroup/flax.slice/cpu.max         >/dev/null
echo 1,5,9,13,17,21,25,29,33,37,41,45,49,53,57,61	| sudo tee /sys/fs/cgroup/flax.slice/cpuset.cpus     >/dev/null

echo 0						| sudo tee /sys/fs/cgroup/flax.slice/cpuset.mems     >/dev/null
echo 4G						| sudo tee /sys/fs/cgroup/flax.slice/memory.max      >/dev/null

# Verify settings
echo "=== Memory ==="
cat /sys/fs/cgroup/flax.slice/memory.max
echo "=== CPU ==="
cat /sys/fs/cgroup/flax.slice/cpu.max
echo "=== CPUset ==="
cat /sys/fs/cgroup/flax.slice/cpuset.cpus
echo "Done."
