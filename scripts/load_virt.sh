#!/bin/bash
MOUNT_SSD="/dev/nvme11n1" # your ssd for prepared DBs

sudo mount $MOUNT_SSD /mnt/ssd

echo "load FLAX"
pushd ../../src
./init_nvmev.sh || exit
popd

echo "copy DB"
mkdir /mnt/nvme/rocks
mkdir /mnt/nvme/rocks/db_run_rocks0.0
# options: 128, 4096, bloom -> bloom is 128B
TYPE="${1:-128}"
(cd /mnt/ssd/$TYPE-rocks/db_run_rocks0.0 && \
find . -type f | \
parallel -j 64 --will-cite --progress \
sudo cp --parents {} /mnt/nvme/rocks/db_run_rocks0.0/)
	
echo "drop cache & sync & sleep"
sudo sync
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches '
sleep 5
