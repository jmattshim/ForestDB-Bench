#!/bin/bash
ssd_name_alias="/dev/disk/by-id/nvme-Dell_DC_NVMe_PE8010_RI_U.2_960GB_SSA9N4572I2309E0A"
#ssd_name_alias="/dev/disk/by-id/nvme-FADU_Delta_U.2_1.92TB_3622FS1HV6U1SX500710"
MOUNT_SSD="$( realpath "${ssd_name_alias}" )"

sudo mount $MOUNT_SSD /mnt/ssd

echo "load virt"
pushd /home/flax/csd_bench/tools/virt
./init_nvmev.sh || exit
popd

echo "copy DB"
mkdir /mnt/nvme/rocks
mkdir /mnt/nvme/rocks/db_run_rocks0.0
# options: 128, 4096, bloom -> bloom is 128B
(cd /mnt/ssd/4096-rocks/db_run_rocks0.0 && \
find . -type f | \
parallel -j 64 --will-cite --progress \
sudo cp --parents {} /mnt/nvme/rocks/db_run_rocks0.0/)
	
echo "drop cache & sync & sleep"
sudo sync
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches '
sleep 5
