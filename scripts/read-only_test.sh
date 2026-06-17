#!/bin/bash

LIBRARY_PATH="../../rocksdb/build"
BENCH_PATH="./rocksdb_bench"

TYPE="${2:-4G}"
WL_PATH="../workloads/read/$TYPE/$1"

if [ "$TYPE" = "25G" ]; then
	./set_cgroup_25G.sh
else
	./set_cgroup_4G.sh
fi

today=$(date "+%Y%m%d%H%M%S")

function do_init() {
	echo "drop cache & sync & sleep"
	sudo sync
	sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches '
	sleep 5

	if [ "$TYPE" = "bloom" ]; then
		./load_virt.sh bloom || exit
	else
		./load_virt.sh || exit
	fi
}

pushd $LIBRARY_PATH
make -j 32 || exit
popd

cmake -DCMAKE_INCLUDE_PATH=../../rocksdb/include -DCMAKE_LIBRARY_PATH=../../rocksdb/build ../
make rocksdb_bench || exit

CPU_AFFINITY=0-127

echo "Set CPU AFFINITY" $CPU_AFFINITY
taskset -p -c $CPU_AFFINITY $$ &> /dev/null
sleep 1

do_init
sudo LD_LIBRARY_PATH=$LIBRARY_PATH cgexec -g cpuset,memory,cpu:/flax.slice $BENCH_PATH -f $WL_PATH/read.ini -e 
cp /mnt/nvme/rocks/db_run_rocks0.0/LOG ycsb_logs/LOG_c-$today

echo "Extract Stats Phase"

./extract_stats.sh LOG_c-$today

sudo chown -R flax:flax logs
