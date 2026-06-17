#!/bin/bash

# MODE: host, csd, assist, opt

pushd logs
sudo rm -rf *.txt
popd
pushd ycsb_logs
sudo rm -rf LOG*
popd
rm summary.txt

MODE=$1
./read-only_test.sh $MODE 4G

today=$(date "+%Y%m%d%H%M%S")
OUTDIR="results_YCSB/$today"
mkdir $OUTDIR
mkdir $OUTDIR/config

cp logs/* $OUTDIR/
cp -r ycsb_logs $OUTDIR/
cp summary.txt $OUTDIR/
