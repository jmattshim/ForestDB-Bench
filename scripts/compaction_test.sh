#!/bin/bash

LIBRARY_PATH="../../rocksdb/build"
BENCH_PATH="./rocksdb_bench"

./set_cgroup_4G.sh

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

	pushd ../../src/
	./init_nvmev.sh
	popd
}

do_init

cmake -DCMAKE_INCLUDE_PATH=../../rocksdb/include -DCMAKE_LIBRARY_PATH=../../rocksdb/build ../
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

