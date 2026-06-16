#!/bin/bash

LIBRARY_PATH="/home/flax/rocksdb-csd/build"
BENCH_PATH="/home/flax/forestdb-bench/build/rocksdb_bench"

/home/flax/flax_set_cgroup.sh

WL_PATH="../workloads/load/$1"

today=$(date "+%Y%m%d%H%M%S")

function do_init() {
	echo "drop cache & sync & sleep"
	sudo sync
	sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches '
	sleep 5

	pushd $LIBRARY_PATH
	make -j 32 || exit
	popd

	pushd /home/flax/csd_bench/tools/virt
	./init_nvmev.sh
	popd
}

do_init

cmake -DCMAKE_INCLUDE_PATH=/home/flax/rocksdb-csd/include -DCMAKE_LIBRARY_PATH=/home/flax/rocksdb-csd/build ../
make rocksdb_bench || exit

CPU_AFFINITY=0-127

echo "Set CPU AFFINITY" $CPU_AFFINITY
taskset -p -c $CPU_AFFINITY $$ &> /dev/null
sleep 1

sudo LD_LIBRARY_PATH=$LIBRARY_PATH cgexec -g cpuset,memory,cpu:/flax.slice $BENCH_PATH -f $WL_PATH/$2.ini
cp /mnt/nvme/rocks/db_run_rocks0.0/LOG ycsb_logs/LOG_$1-$2-$today

OUTPUT="summary.txt"

echo "" >> $OUTPUT
echo $1-$2 >> $OUTPUT

echo "" >> $OUTPUT
cat ycsb_logs/LOG_$1-$2-$today | ./breakdown_compaction.py >> $OUTPUT

echo "" >> $OUTPUT
cat ycsb_logs/LOG_$1-$2-$today | ./cdf_write_latency.py >> $OUTPUT

sudo chown -R flax:flax logs
