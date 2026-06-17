#!/bin/bash

# MODE: host, csd, assist, opt

pushd logs
sudo rm -rf *.txt
popd
pushd ycsb_logs
sudo rm -rf LOG*
popd
rm summary.txt

# TYPE: 4G (default) | 25G | bloom | skew
TYPE="${1:-4G}"

MODE="host"
./read-only_test.sh $MODE $TYPE

MODE="csd"
./read-only_test.sh $MODE $TYPE

MODE="flax"
./read-only_test.sh $MODE $TYPE

MODE="compound"
./read-only_test.sh $MODE $TYPE

MODE="compound"
pushd /home/flax/rocksdb-csd/db
cp 20.cc version_set.cc
popd
./read-only_test.sh $MODE $TYPE

pushd /home/flax/rocksdb-csd/db
cp 40.cc version_set.cc
popd
./read-only_test.sh $MODE $TYPE

pushd /home/flax/rocksdb-csd/db
cp 60.cc version_set.cc
popd
./read-only_test.sh $MODE $TYPE

pushd /home/flax/rocksdb-csd/db
cp 80.cc version_set.cc
popd
./read-only_test.sh $MODE $TYPE

pushd /home/flax/rocksdb-csd/db
git checkout version_set.cc
popd

today=$(date "+%Y%m%d%H%M%S")
OUTDIR="results_YCSB/$today"
mkdir $OUTDIR
mkdir $OUTDIR/config

cp logs/* $OUTDIR/
cp -r ycsb_logs $OUTDIR/
cp summary.txt $OUTDIR/
