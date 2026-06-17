#!/bin/bash

LIBRARY_PATH="/home/flax/rocksdb-csd/build"
BENCH_PATH="/home/flax/forestdb-bench/build/rocksdb_bench"

/home/flax/flax_set_cgroup.sh

# Usage: ./read-only_test.sh <workload> [size]
#   workload : workload name (e.g. workloada)
#   size     : 4G (default) | 25G | bloom
SIZE="${2:-4G}"
WL_PATH="../workloads/read/$SIZE/$1"

today=$(date "+%Y%m%d%H%M%S")

function do_init() {
	echo "drop cache & sync & sleep"
	sudo sync
	sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches '
	sleep 5

	./load_virt.sh || exit
}

pushd $LIBRARY_PATH
make -j 32 || exit
popd

cmake -DCMAKE_INCLUDE_PATH=/home/flax/rocksdb-csd/include -DCMAKE_LIBRARY_PATH=/home/flax/rocksdb-csd/build ../
make rocksdb_bench || exit

CPU_AFFINITY=0-127

echo "Set CPU AFFINITY" $CPU_AFFINITY
taskset -p -c $CPU_AFFINITY $$ &> /dev/null
sleep 1

do_init
#sleep 60
#sudo sh -c 'echo 1 > /proc/nvmev/io_stat '
sudo LD_LIBRARY_PATH=$LIBRARY_PATH cgexec -g cpuset,memory,cpu:/flax.slice $BENCH_PATH -f $WL_PATH/uniform.ini -e 
#sudo LD_LIBRARY_PATH=$LIBRARY_PATH cgexec -g cpuset,memory,cpu:/flax.slice $BENCH_PATH -f $WL_PATH/skewed.ini -e 
cp /mnt/nvme/rocks/db_run_rocks0.0/LOG ycsb_logs/LOG_c-$today
#sudo sh -c 'cat /proc/nvmev/io_stat ' >> stat.txt

echo "Extract Stats Phase"

./extract_stats.sh LOG_c-$today

sudo chown -R flax:flax logs
