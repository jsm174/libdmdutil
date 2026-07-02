#!/bin/bash

set -e

if [ -z "${MSYS2_PATH}" ]; then
   MSYS2_PATH="/c/msys64"
fi

echo "MSYS2_PATH: ${MSYS2_PATH}"
echo ""

source ./platforms/config.sh

echo "Building libraries..."
echo "  LIBUSB_SHA: ${LIBUSB_SHA}"
echo "  LIBZEDMD_SHA: ${LIBZEDMD_SHA}"
echo "  LIBSERUM_SHA: ${LIBSERUM_SHA}"
echo "  LIBPUPDMD_SHA: ${LIBPUPDMD_SHA}"
echo "  LIBVNI_SHA: ${LIBVNI_SHA}"
echo ""

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
sed -i.bak 's/libusb-1\.0/libusb64-1.0/g' libusb/Makefile.am
sed -i.bak 's/libusb_1_0/libusb64_1_0/g' libusb/Makefile.am
mv libusb/libusb-1.0.def libusb/libusb64-1.0.def
mv libusb/libusb-1.0.rc libusb/libusb64-1.0.rc
sed -i.bak 's/libusb-1\.0/libusb64-1.0/g' libusb/libusb64-1.0.def
sed -i.bak 's/libusb-1\.0/libusb64-1.0/g' libusb/libusb64-1.0.rc
CURRENT_DIR="$(pwd)"
MSYSTEM=UCRT64 "${MSYS2_PATH}/usr/bin/bash.exe" -l -c "
   cd \"${CURRENT_DIR}\" &&
   ./autogen.sh &&
   ./configure --enable-shared &&
   make -j\$(nproc)
"
mkdir -p ../../third-party/include/libusb-1.0
cp libusb/libusb.h ../../third-party/include/libusb-1.0
cp libusb/.libs/libusb64-1.0.dll.a ../../third-party/build-libs/win/x64/libusb64-1.0.lib
cp libusb/.libs/libusb64-1.0.dll ../../third-party/runtime-libs/win/x64/
cd ..

#
# build libzedmd and copy to external
#

if ! use_prebuilt_source libzedmd; then
   curl -sL https://github.com/PPUC/libzedmd/archive/${LIBZEDMD_SHA}.tar.gz -o libzedmd-${LIBZEDMD_SHA}.tar.gz
   tar xzf libzedmd-${LIBZEDMD_SHA}.tar.gz
   mv libzedmd-${LIBZEDMD_SHA} libzedmd
   cd libzedmd
   BUILD_TYPE=${BUILD_TYPE} platforms/win/x64/external.sh
   cmake \
      -G "Visual Studio 18 2026" \
      -DPLATFORM=win \
      -DARCH=x64 \
      -DBUILD_SHARED=ON \
      -DBUILD_STATIC=OFF \
      -B build
   cmake --build build --config ${BUILD_TYPE}
fi
cp src/ZeDMD.h ${SOURCE_ROOT}/third-party/include/
cp third-party/include/cargs.h ${SOURCE_ROOT}/third-party/include/
cp -r third-party/include/komihash ${SOURCE_ROOT}/third-party/include/
cp -r third-party/include/sockpp ${SOURCE_ROOT}/third-party/include/
cp third-party/include/FrameUtil.h ${SOURCE_ROOT}/third-party/include/
cp third-party/include/libserialport.h ${SOURCE_ROOT}/third-party/include/
cp third-party/build-libs/win/x64/cargs64.lib ${SOURCE_ROOT}/third-party/build-libs/win/x64/
cp third-party/runtime-libs/win/x64/cargs64.dll ${SOURCE_ROOT}/third-party/runtime-libs/win/x64/
cp third-party/build-libs/win/x64/libserialport64.lib ${SOURCE_ROOT}/third-party/build-libs/win/x64/
cp third-party/runtime-libs/win/x64/libserialport64-0.dll ${SOURCE_ROOT}/third-party/runtime-libs/win/x64/
cp third-party/build-libs/win/x64/sockpp64.lib ${SOURCE_ROOT}/third-party/build-libs/win/x64/
cp third-party/runtime-libs/win/x64/sockpp64.dll ${SOURCE_ROOT}/third-party/runtime-libs/win/x64/
cp third-party/runtime-libs/win/x64/libgcc_s_seh-1.dll ${SOURCE_ROOT}/third-party/runtime-libs/win/x64/
cp third-party/runtime-libs/win/x64/libstdc++-6.dll ${SOURCE_ROOT}/third-party/runtime-libs/win/x64/
cp third-party/runtime-libs/win/x64/libwinpthread-1.dll ${SOURCE_ROOT}/third-party/runtime-libs/win/x64/
cp build/${BUILD_TYPE}/zedmd64.lib ${SOURCE_ROOT}/third-party/build-libs/win/x64/
cp build/${BUILD_TYPE}/zedmd64.dll ${SOURCE_ROOT}/third-party/runtime-libs/win/x64/
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
      -G "Visual Studio 18 2026" \
      -DPLATFORM=win \
      -DARCH=x64 \
      -DBUILD_SHARED=ON \
      -DBUILD_STATIC=OFF \
      -B build
   cmake --build build --config ${BUILD_TYPE}
fi
cp -r third-party/include/lz4 ${SOURCE_ROOT}/third-party/include/
cp src/LZ4Stream.h ${SOURCE_ROOT}/third-party/include/
cp src/SceneGenerator.h ${SOURCE_ROOT}/third-party/include/
cp src/serum.h ${SOURCE_ROOT}/third-party/include/
cp src/TimeUtils.h ${SOURCE_ROOT}/third-party/include/
cp src/serum-decode.h ${SOURCE_ROOT}/third-party/include/
cp build/${BUILD_TYPE}/serum64.lib ${SOURCE_ROOT}/third-party/build-libs/win/x64/
cp build/${BUILD_TYPE}/serum64.dll ${SOURCE_ROOT}/third-party/runtime-libs/win/x64/
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
      -G "Visual Studio 18 2026" \
      -DPLATFORM=win \
      -DARCH=x64 \
      -DBUILD_SHARED=ON \
      -DBUILD_STATIC=OFF \
      -B build
   cmake --build build --config ${BUILD_TYPE}
fi
cp src/pupdmd.h ${SOURCE_ROOT}/third-party/include/
cp build/${BUILD_TYPE}/pupdmd64.lib ${SOURCE_ROOT}/third-party/build-libs/win/x64/
cp build/${BUILD_TYPE}/pupdmd64.dll ${SOURCE_ROOT}/third-party/runtime-libs/win/x64/
cd "${SOURCE_ROOT}/external"

#
# build libvni and copy to external
#

if ! use_prebuilt_source libvni; then
   curl -sL https://github.com/PPUC/libvni/archive/${LIBVNI_SHA}.tar.gz -o libvni-${LIBVNI_SHA}.tar.gz
   tar xzf libvni-${LIBVNI_SHA}.tar.gz
   mv libvni-${LIBVNI_SHA} libvni
   cd libvni
   platforms/win/x64/external.sh
   cmake \
      -G "Visual Studio 18 2026" \
      -DPLATFORM=win \
      -DARCH=x64 \
      -DBUILD_SHARED=ON \
      -DBUILD_STATIC=OFF \
      -B build
   cmake --build build --config ${BUILD_TYPE}
fi
cp src/vni.h ${SOURCE_ROOT}/third-party/include/
cp build/${BUILD_TYPE}/vni64.lib ${SOURCE_ROOT}/third-party/build-libs/win/x64/
cp build/${BUILD_TYPE}/vni64.dll ${SOURCE_ROOT}/third-party/runtime-libs/win/x64/
cd "${SOURCE_ROOT}/external"
