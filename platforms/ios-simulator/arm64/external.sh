#!/bin/bash

set -e

source ./platforms/config.sh

echo "Building libraries..."
echo "  LIBZEDMD_SHA: ${LIBZEDMD_SHA}"
echo "  LIBSERUM_SHA: ${LIBSERUM_SHA}"
echo "  LIBPUPDMD_SHA: ${LIBPUPDMD_SHA}"
echo "  LIBVNI_SHA: ${LIBVNI_SHA}"
echo ""

NUM_PROCS=$(sysctl -n hw.ncpu)

rm -rf external
mkdir external
cd external

#
# build libzedmd and copy to external
#

if ! use_prebuilt_source libzedmd; then
   curl -sL https://github.com/PPUC/libzedmd/archive/${LIBZEDMD_SHA}.tar.gz -o libzedmd-${LIBZEDMD_SHA}.tar.gz
   tar xzf libzedmd-${LIBZEDMD_SHA}.tar.gz
   mv libzedmd-${LIBZEDMD_SHA} libzedmd
   cd libzedmd
   BUILD_TYPE=${BUILD_TYPE} platforms/ios-simulator/arm64/external.sh
   cmake \
      -DPLATFORM=ios-simulator \
      -DARCH=arm64 \
      -DBUILD_SHARED=OFF \
      -DBUILD_STATIC=ON \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -B build
   cmake --build build -- -j${NUM_PROCS}
fi
cp src/ZeDMD.h ${SOURCE_ROOT}/third-party/include/
cp -r third-party/include/komihash ${SOURCE_ROOT}/third-party/include/
cp -r third-party/include/sockpp ${SOURCE_ROOT}/third-party/include/
cp third-party/include/FrameUtil.h ${SOURCE_ROOT}/third-party/include/
cp -a third-party/build-libs/ios-simulator/arm64/libsockpp.a ${SOURCE_ROOT}/third-party/build-libs/ios-simulator/arm64/
cp build/libzedmd.a ${SOURCE_ROOT}/third-party/build-libs/ios-simulator/arm64/
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
      -DPLATFORM=ios-simulator \
      -DARCH=arm64 \
      -DBUILD_SHARED=OFF \
      -DBUILD_STATIC=ON \
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
cp build/libserum.a ${SOURCE_ROOT}/third-party/build-libs/ios-simulator/arm64/
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
      -DPLATFORM=ios-simulator \
      -DARCH=arm64 \
      -DBUILD_SHARED=OFF \
      -DBUILD_STATIC=ON \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -B build
   cmake --build build -- -j${NUM_PROCS}
fi
cp src/pupdmd.h ${SOURCE_ROOT}/third-party/include/
cp build/libpupdmd.a ${SOURCE_ROOT}/third-party/build-libs/ios-simulator/arm64/
cd "${SOURCE_ROOT}/external"

#
# build libvni and copy to external
#

if ! use_prebuilt_source libvni; then
   curl -sL https://github.com/PPUC/libvni/archive/${LIBVNI_SHA}.tar.gz -o libvni-${LIBVNI_SHA}.tar.gz
   tar xzf libvni-${LIBVNI_SHA}.tar.gz
   mv libvni-${LIBVNI_SHA} libvni
   cd libvni
   platforms/ios-simulator/arm64/external.sh
   cmake \
      -DPLATFORM=ios-simulator \
      -DARCH=arm64 \
      -DBUILD_SHARED=OFF \
      -DBUILD_STATIC=ON \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -B build
   cmake --build build -- -j${NUM_PROCS}
fi
cp src/vni.h ${SOURCE_ROOT}/third-party/include/
cp build/libvni.a ${SOURCE_ROOT}/third-party/build-libs/ios-simulator/arm64/
cd "${SOURCE_ROOT}/external"
