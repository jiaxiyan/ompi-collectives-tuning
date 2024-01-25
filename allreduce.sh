#!/bin/bash
set -euxo pipefail

cd ~

[ -d osu-micro-benchmarks ] || wget -O osu-micro-benchmarks.tar.gz https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.3.tar.gz
tar -xvf osu-micro-benchmarks.tar.gz
pushd osu-micro-benchmarks
./configure --prefix=${HOME}/osu-micro-benchmarks/install CC=${HOME}/ompi/install/bin/mpicc CXX=${HOME}/ompi/install/bin/mpicxx
make -j install
popd

[ -d ompi-collectives-tuning ] || git clone https://github.com/open-mpi/ompi-collectives-tuning.git
pushd ompi-collectives-tuning
./run_and_analyze.sh -c config-allreduce --scheduler slurm
popd