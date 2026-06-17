#!/bin/bash

LIBRARY_PATH="../../rocksdb/build"
BENCH_PATH="./rocksdb_bench"

TYPE="${1:-128}" # 128, 4096, bloom 
WL_PATH="../workloads/prepare"

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

sudo LD_LIBRARY_PATH=$LIBRARY_PATH $BENCH_PATH -f $WL_PATH/$TYPE.ini

## Copy prepared DB to /mnt/ssd
MOUNT_SSD="/dev/nvme11n1" # your ssd for prepared DBs

sudo mount $MOUNT_SSD /mnt/ssd

mkdir -p /mnt/ssd/$TYPE-rocks/db_run_rocks0.0

(cd /mnt/nvme/rocks/db_run_rocks0.0 && \
find . -type f | \
parallel -j 64 --will-cite --progress \
sudo cp --parents {} /mnt/ssd/$TYPE-rocks/db_run_rocks0.0/)

echo "drop cache & sync & sleep"
sudo sync
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches '
sleep 5
