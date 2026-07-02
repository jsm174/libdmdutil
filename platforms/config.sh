#!/bin/bash

set -e

LIBZEDMD_SHA=5c44646f2af4b1419b4cdcaed3a2799ca9439221
LIBSERUM_SHA=21b28325c4272724e719ab2d17481d851eaf9fd8
LIBPUPDMD_SHA=4a1123220e6dce73c87cc584494df2ac82cb6f4c
LIBVNI_SHA=7258e2fa0d086e1224d6510d44a61879e6b344b1
LIBUSB_SHA=15a7ebb4d426c5ce196684347d2b7cafad862626

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for source_dir_var in LIBZEDMD_SOURCE_DIR LIBSERUM_SOURCE_DIR LIBPUPDMD_SOURCE_DIR LIBVNI_SOURCE_DIR; do
   source_dir="${!source_dir_var}"
   if [ -n "${source_dir}" ]; then
      if [ ! -d "${source_dir}" ]; then
         echo "${source_dir_var}=${source_dir} is not a directory" >&2
         exit 1
      fi
      eval "${source_dir_var}=\"$(cd "${source_dir}" && pwd)\""
      echo "Local source override: ${source_dir_var}=${!source_dir_var}"
   fi
done

use_prebuilt_source() {
   local name="$1"
   local source_dir_var
   source_dir_var="$(echo "${name}" | tr '[:lower:]' '[:upper:]')_SOURCE_DIR"
   local source_dir="${!source_dir_var}"

   if [ -z "${source_dir}" ]; then
      return 1
   fi

   if [ ! -d "${source_dir}/build" ]; then
      echo "${source_dir_var}=${source_dir} has no build directory. Build it for this platform first." >&2
      exit 1
   fi

   echo "Using prebuilt ${name} from ${source_dir}"
   cd "${source_dir}"
}

if [ -z "${BUILD_TYPE}" ]; then
   BUILD_TYPE="Release"
fi

echo "Build type: ${BUILD_TYPE}"
echo ""
