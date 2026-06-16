#!/bin/bash

# MODE: host, csd, assist, opt

pushd logs
sudo rm -rf *.txt
popd
pushd ycsb_logs
sudo rm -rf LOG*
popd

rm summary.txt

MODE="host" # host, csd, flax
for ((iter = 0; iter < 1; iter += 1)); do
	for ((vlen = 4096; vlen <= 4096; vlen *= 2)); do
		./compaction_test.sh $MODE $vlen | tee ops_log-$iter-$vlen
		if grep -q "ERR" ops_log-$iter-$vlen; then
			source ~/pushover.sh
			push_to_mobile "RocksDB Error" "$(basename "$0") for $MODE running $vlen at $(basename "$PWD") $(hostname) @ $(date)"
        fi
		sleep 180
	done
done

today=$(date "+%Y%m%d%H%M%S")
OUTDIR="results_YCSB/$today"
mkdir $OUTDIR
mkdir $OUTDIR/config

cp logs/* $OUTDIR/
cp -r ycsb_logs $OUTDIR/
cp summary.txt $OUTDIR/
cp /home/flax/csd_bench/tools/virt/csd_dispatcher.h $OUTDIR/config

source ~/pushover.sh
push_to_mobile "linux_notification" "$(basename "$0") for $MODE at $(basename "$PWD") done! $(hostname) @ $(date)"
