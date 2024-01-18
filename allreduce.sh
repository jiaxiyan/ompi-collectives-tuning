#!/bin/bash
set -euxo pipefail

export HOME=/fsx
cd ~

[ -d libfabric ] || git clone https://github.com/ofiwg/libfabric.git -b main
pushd libfabric
./autogen.sh
./configure --prefix=${HOME}/libfabric/install --disable-verbs --disable-psm3 --disable-opx --disable-usnic --disable-rstream --enable-efa
make -j install
popd

[ -d ompi ] || git clone --recursive https://github.com/jiaxiyan/ompi.git -b allreduce
pushd ompi
./autogen.pl
./configure --prefix=/fsx/ompi/install --with-libfabric=/fsx/libfabric/install --with-libevent=internal --with-hwloc=internal
make -j install
popd

[ -d osu-micro-benchmarks ] || git clone https://github.com/wenduwan/osu-micro-benchmarks.git -b distribution
pushd osu-micro-benchmarks
autoreconf -f -i
./configure --prefix=${HOME}/osu-micro-benchmarks/install CC=${HOME}/ompi/install/bin/mpicc CXX=${HOME}/ompi/install/bin/mpicxx
make -j install
popd

/fsx/ompi/install/bin/mpirun --hostfile /fsx/PortaFiducia/hostfile --bind-to core -x LD_LIBRARY_PATH=/fsx/libfabric/install/lib:/fsx/ompi/install/lib -x PATH=/fsx/ompi/install/bin --map-by ppr:64:node --mca coll_han_allreduce_use_algorithm simple /fsx/osu-micro-benchmarks/install/libexec/osu-micro-benchmarks/mpi/collective/osu_allreduce