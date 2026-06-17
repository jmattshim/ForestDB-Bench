#!/bin/bash

pushd logs
sudo rm -rf *.txt
popd
pushd ycsb_logs
sudo rm -rf LOG*
popd

rm summary.txt

MODE=$1 # A, B
for ((iter = 0; iter < 1; iter += 1)); do
	for ((vlen = 4096; vlen <= 4096; vlen *= 2)); do
		./compaction_test.sh $MODE $vlen | tee ops_log-$iter-$vlen
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

