#!/bin/bash

set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TOOLCHAIN="${DIR}/../mipsel-toolchain"
ROOTFS="${DIR}/../rootfs"
GWLIB="${DIR}/../gwlib"
SQLITE="${DIR}/../sqlite"
_BUILD="${DIR}/_build"
_BUILD_ROOTFS="${_BUILD}/rootfs"

rm -rf ${_BUILD}
mkdir -p "${_BUILD}"

cp -r "${ROOTFS}" "${_BUILD}"
(cd "${GWLIB}" && cp *.so* *.a *.la "${_BUILD_ROOTFS}/lib")
(cd "${GWLIB}/include" && cp -r * "${_BUILD_ROOTFS}/include")
(cd "${SQLITE}" && cp *.h "${_BUILD_ROOTFS}/include")

CONFIG_SITE=config.site CC="${TOOLCHAIN}/bin/mipsel-linux-gcc" CXX="${TOOLCHAIN}/bin/mipsel-linux-g++" AR="${TOOLCHAIN}/bin/mipsel-linux-ar" RANLIB="${TOOLCHAIN}/bin/mipsel-linux-ranlib" ./configure --host=mipsel-linux --build=x86_64-linux-gnu --disable-ipv6

export PYTHON_XCOMPILE_DEPENDENCIES_PREFIX="${_BUILD_ROOTFS}"

make BLDSHARED="${TOOLCHAIN}/bin/mipsel-linux-gcc -shared" CROSS_COMPILE="${TOOLCHAIN}/bin/mipsel-linux-" HOSTARCH=mipsel-linux BUILDARCH=x86_64-linux-gnu
make install BLDSHARED="${TOOLCHAIN}/bin/mipsel-linux-gcc -shared" CROSS_COMPILE="${TOOLCHAIN}/bin/mipsel-linux-" prefix="${_BUILD}/python" ENSUREPIP=no
