#!/bin/bash

# MODE: host, csd, assist, opt

pushd logs
sudo rm -rf *.txt
popd
pushd ycsb_logs
sudo rm -rf LOG*
popd
rm summary.txt

#MODE="host"
#./read-only_test.sh $MODE | tee ops_log-host

#MODE="csd"
#./read-only_test.sh $MODE | tee ops_log-ccsd

MODE="flax"
./read-only_test.sh $MODE | tee ops_log-dcsd

MODE="compound"
./read-only_test.sh $MODE | tee ops_log-compound

#MODE="compound"
#pushd /home/flax/rocksdb-csd/db
#cp 20.cc version_set.cc
#popd
#./read-only_test.sh $MODE | tee ops_log-20
#
#pushd /home/flax/rocksdb-csd/db
#cp 40.cc version_set.cc
#popd
#./read-only_test.sh $MODE | tee ops_log-40
#
#pushd /home/flax/rocksdb-csd/db
#cp 60.cc version_set.cc
#popd
#./read-only_test.sh $MODE | tee ops_log-60
#
#pushd /home/flax/rocksdb-csd/db
#cp 80.cc version_set.cc
#popd
#./read-only_test.sh $MODE | tee ops_log-80
#
#pushd /home/flax/rocksdb-csd/db
#git checkout version_set.cc
#popd

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
