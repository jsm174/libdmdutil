#!/bin/bash

set -e

source ./platforms/config.sh

echo "Building libraries..."
echo "  LIBUSB_SHA: ${LIBUSB_SHA}"
echo "  LIBZEDMD_SHA: ${LIBZEDMD_SHA}"
echo "  LIBSERUM_SHA: ${LIBSERUM_SHA}"
echo "  LIBPUPDMD_SHA: ${LIBPUPDMD_SHA}"
echo "  LIBVNI_SHA: ${LIBVNI_SHA}"
echo ""

NUM_PROCS=$(nproc)

rm -rf external
mkdir external
cd external

#
# build libusb and copy to third-party
#

curl -sL https://github.com/libusb/libusb/archive/${LIBUSB_SHA}.tar.gz -o libusb-${LIBUSB_SHA}.tar.gz
tar xzf libusb-${LIBUSB_SHA}.tar.gz
mv libusb-${LIBUSB_SHA} libusb
cd libusb
./autogen.sh
./configure \
   --enable-shared
make -j${NUM_PROCS}
mkdir -p ../../third-party/include/libusb-1.0
cp libusb/libusb.h ../../third-party/include/libusb-1.0
cp -a libusb/.libs/libusb-1.0.{so,so.*} ../../third-party/runtime-libs/linux/aarch64/
cd ..

#
# build libzedmd and copy to external
#

if ! use_prebuilt_source libzedmd; then
   curl -sL https://github.com/PPUC/libzedmd/archive/${LIBZEDMD_SHA}.tar.gz -o libzedmd-${LIBZEDMD_SHA}.tar.gz
   tar xzf libzedmd-${LIBZEDMD_SHA}.tar.gz
   mv libzedmd-${LIBZEDMD_SHA} libzedmd
   cd libzedmd
   BUILD_TYPE=${BUILD_TYPE} platforms/linux/aarch64/external.sh
   cmake \
      -DPLATFORM=linux \
      -DARCH=aarch64 \
      -DBUILD_SHARED=ON \
      -DBUILD_STATIC=OFF \
      -DSPI_SUPPORT=ON \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -B build
   cmake --build build -- -j${NUM_PROCS}
fi
cp src/ZeDMD.h ${SOURCE_ROOT}/third-party/include/
cp third-party/include/libserialport.h ${SOURCE_ROOT}/third-party/include/
cp third-party/include/cargs.h ${SOURCE_ROOT}/third-party/include/
cp -r third-party/include/komihash ${SOURCE_ROOT}/third-party/include/
cp -r third-party/include/sockpp ${SOURCE_ROOT}/third-party/include/
cp third-party/include/FrameUtil.h ${SOURCE_ROOT}/third-party/include/
cp third-party/runtime-libs/linux/aarch64/libcargs.so ${SOURCE_ROOT}/third-party/runtime-libs/linux/aarch64/
cp -a third-party/runtime-libs/linux/aarch64/libserialport.{so,so.*} ${SOURCE_ROOT}/third-party/runtime-libs/linux/aarch64/
cp -a third-party/runtime-libs/linux/aarch64/libsockpp.{so,so.*} ${SOURCE_ROOT}/third-party/runtime-libs/linux/aarch64/
cp -a build/libzedmd.{so,so.*} ${SOURCE_ROOT}/third-party/runtime-libs/linux/aarch64/
cp -r test ${SOURCE_ROOT}/
cd "${SOURCE_ROOT}/external"

#
# build libserum and copy to external
#

if ! use_prebuilt_source libserum; then
   curl -sL https://github.com/PPUC/libserum/archive/${LIBSERUM_SHA}.tar.gz -o libserum-${LIBSERUM_SHA}.tar.gz
   tar xzf libserum-${LIBSERUM_SHA}.tar.gz
   mv libserum-${LIBSERUM_SHA} libserum
   cd libserum
   cmake \
      -DPLATFORM=linux \
      -DARCH=aarch64 \
      -DBUILD_SHARED=ON \
      -DBUILD_STATIC=OFF \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -B build
   cmake --build build -- -j${NUM_PROCS}
fi
cp -r third-party/include/lz4 ${SOURCE_ROOT}/third-party/include/
cp src/LZ4Stream.h ${SOURCE_ROOT}/third-party/include/
cp src/SceneGenerator.h ${SOURCE_ROOT}/third-party/include/
cp src/serum.h ${SOURCE_ROOT}/third-party/include/
cp src/TimeUtils.h ${SOURCE_ROOT}/third-party/include/
cp src/serum-decode.h ${SOURCE_ROOT}/third-party/include/
cp -a build/libserum.{so,so.*} ${SOURCE_ROOT}/third-party/runtime-libs/linux/aarch64/
cd "${SOURCE_ROOT}/external"

#
# build libpupdmd and copy to external
#

if ! use_prebuilt_source libpupdmd; then
   curl -sL https://github.com/PPUC/libpupdmd/archive/${LIBPUPDMD_SHA}.tar.gz -o libpupdmd-${LIBPUPDMD_SHA}.tar.gz
   tar xzf libpupdmd-${LIBPUPDMD_SHA}.tar.gz
   mv libpupdmd-${LIBPUPDMD_SHA} libpupdmd
   cd libpupdmd
   cmake \
      -DPLATFORM=linux \
      -DARCH=aarch64 \
      -DBUILD_SHARED=ON \
      -DBUILD_STATIC=OFF \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -B build
   cmake --build build -- -j${NUM_PROCS}
fi
cp src/pupdmd.h ${SOURCE_ROOT}/third-party/include/
cp -a build/libpupdmd.{so,so.*} ${SOURCE_ROOT}/third-party/runtime-libs/linux/aarch64/
cd "${SOURCE_ROOT}/external"

#
# build libvni and copy to external
#

if ! use_prebuilt_source libvni; then
   curl -sL https://github.com/PPUC/libvni/archive/${LIBVNI_SHA}.tar.gz -o libvni-${LIBVNI_SHA}.tar.gz
   tar xzf libvni-${LIBVNI_SHA}.tar.gz
   mv libvni-${LIBVNI_SHA} libvni
   cd libvni
   platforms/linux/aarch64/external.sh
   cmake \
      -DPLATFORM=linux \
      -DARCH=aarch64 \
      -DBUILD_SHARED=ON \
      -DBUILD_STATIC=OFF \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -B build
   cmake --build build -- -j${NUM_PROCS}
fi
cp src/vni.h ${SOURCE_ROOT}/third-party/include/
cp -a build/libvni.{so,so.*} ${SOURCE_ROOT}/third-party/runtime-libs/linux/aarch64/
cd "${SOURCE_ROOT}/external"
