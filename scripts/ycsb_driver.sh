#!/bin/bash

# MODE: host, csd, assist, opt

pushd logs
sudo rm -rf *.txt
popd
pushd ycsb_logs
sudo rm -rf LOG*
popd
rm summary.txt
rm ops_log-*

MODE="host" # host, csd, compaction-only, read-only, flax
for ((iter = 0; iter < 1; iter += 1)); do
	./ycsb_run.sh $MODE | tee ops_log-$iter-$MODE

	if grep -q "ERR" ops_log-$iter-$MODE; then
		source ~/pushover.sh
		push_to_mobile "RocksDB Error during YCSB" "$(basename "$0") for $MODE at $(basename "$PWD") $(hostname) @ $(date)"
	fi

	#sleep 300
done

today=$(date "+%Y%m%d%H%M%S")
OUTDIR="results_YCSB/$today"
mkdir $OUTDIR
mkdir $OUTDIR/config

cp logs/* $OUTDIR/
cp -r ycsb_logs $OUTDIR/
cp /home/flax/csd_bench/tools/virt/csd_dispatcher.h $OUTDIR/config
cp summary.txt $OUTDIR/

source ~/pushover.sh
push_to_mobile "linux_notification" "ycsb_driver for $MODE at $(basename "$PWD") done! $(hostname) @ $(date)"
