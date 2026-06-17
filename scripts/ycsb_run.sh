#!/bin/bash

LIBRARY_PATH="../../rocksdb/build"
BENCH_PATH="./rocksdb_bench"

./set_cgroup_4G.sh

TYPE="${2:-128}" # 128, 4096
WL_PATH="../workloads/YCSB/4G/$TYPE/$1"

today=$(date "+%Y%m%d%H%M%S")

function do_init() {
	echo "drop cache & sync & sleep"
	sudo sync
	sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches '
	sleep 5

	./load_virt.sh $TYPE || exit
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
sudo LD_LIBRARY_PATH=$LIBRARY_PATH cgexec -g cpuset,memory,cpu:/flax.slice $BENCH_PATH -f $WL_PATH/ycsb_a.ini -e
cp /mnt/nvme/rocks/db_run_rocks0.0/LOG ycsb_logs/LOG_a-$today

do_init
sudo LD_LIBRARY_PATH=$LIBRARY_PATH cgexec -g cpuset,memory,cpu:/flax.slice $BENCH_PATH -f $WL_PATH/ycsb_b.ini -e 
cp /mnt/nvme/rocks/db_run_rocks0.0/LOG ycsb_logs/LOG_b-$today

do_init
sudo LD_LIBRARY_PATH=$LIBRARY_PATH cgexec -g cpuset,memory,cpu:/flax.slice $BENCH_PATH -f $WL_PATH/ycsb_c.ini -e 
cp /mnt/nvme/rocks/db_run_rocks0.0/LOG ycsb_logs/LOG_c-$today

do_init
sudo LD_LIBRARY_PATH=$LIBRARY_PATH cgexec -g cpuset,memory,cpu:/flax.slice $BENCH_PATH -f $WL_PATH/ycsb_d.ini -e 
cp /mnt/nvme/rocks/db_run_rocks0.0/LOG ycsb_logs/LOG_d-$today

do_init
sudo LD_LIBRARY_PATH=$LIBRARY_PATH cgexec -g cpuset,memory,cpu:/flax.slice $BENCH_PATH -f $WL_PATH/ycsb_e.ini -e 
cp /mnt/nvme/rocks/db_run_rocks0.0/LOG ycsb_logs/LOG_e-$today

do_init
sudo LD_LIBRARY_PATH=$LIBRARY_PATH cgexec -g cpuset,memory,cpu:/flax.slice $BENCH_PATH -f $WL_PATH/ycsb_f.ini -e 
cp /mnt/nvme/rocks/db_run_rocks0.0/LOG ycsb_logs/LOG_f-$today

echo "Extract Stats Phase"

./extract_stats.sh LOG_a-$today
./extract_stats.sh LOG_b-$today
./extract_stats.sh LOG_c-$today
./extract_stats.sh LOG_d-$today
./extract_stats.sh LOG_e-$today
./extract_stats.sh LOG_f-$today

