#!/bin/bash

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* . || true

if [[ "$target_platform" == win-* ]]; then
  export PREFIX=${PREFIX}/Library
fi

extra_configure_args=()
if [[ "$target_platform" == "win-arm64" ]]; then
  set -e
  # MSYS2 runs under x64 emulation; the compiler and all tests are native ARM64.
  extra_configure_args=(--build=aarch64-pc-mingw32 --host=aarch64-pc-mingw32)
  export CFLAGS="${CFLAGS} -std=gnu17"
  export PATH="$PWD/src/.libs:$PATH"
fi

./configure --prefix=$PREFIX "${extra_configure_args[@]}" \
            --with-gmp=$PREFIX \
            --disable-static \
            --enable-thread-safe

make -j${CPU_COUNT}
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != 1 && "${CROSSCOMPILING_EMULATOR}" == "" ]]; then
  make check
fi
make install

if [[ "$target_platform" == "win-64" ]]; then
  cp ${PREFIX}/lib/libmpfr.dll.a ${PREFIX}/lib/mpfr.lib
fi

if [[ "$target_platform" == "win-arm64" ]]; then
  # Native MSVC-style libtool installs its DLL beside the import library.
  mkdir -p "$PREFIX/bin"
  mv "$PREFIX/lib/mpfr-6.dll" "$PREFIX/bin/mpfr-6.dll"
  mv "$PREFIX/lib/mpfr.dll.lib" "$PREFIX/lib/mpfr.lib"
  test -f "$PREFIX/bin/mpfr-6.dll"
  test -f "$PREFIX/lib/mpfr.lib"
fi
