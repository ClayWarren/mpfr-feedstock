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
  # Use the patched release configure script without regenerating Autotools files.
  extra_configure_args=(--build=aarch64-pc-mingw32 --host=aarch64-pc-mingw32 --disable-maintainer-mode)
  export CFLAGS="${CFLAGS} -std=gnu17"
  export PATH="$PWD/src/.libs:$PATH"
fi

./configure --prefix=$PREFIX "${extra_configure_args[@]}" \
            --with-gmp=$PREFIX \
            --disable-static \
            --enable-thread-safe

make -j${CPU_COUNT}
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != 1 && "${CROSSCOMPILING_EMULATOR}" == "" ]]; then
  if [[ "$target_platform" == "win-arm64" ]]; then
    make check -j${CPU_COUNT}
  else
    make check
  fi
fi
make install

if [[ "$target_platform" == "win-64" ]]; then
  cp ${PREFIX}/lib/libmpfr.dll.a ${PREFIX}/lib/mpfr.lib
fi

if [[ "$target_platform" == "win-arm64" ]]; then
  # Keep the DLL on PATH with either native libtool installation layout.
  mkdir -p "$PREFIX/bin"
  if [[ -f "$PREFIX/lib/mpfr-6.dll" ]]; then
    mv "$PREFIX/lib/mpfr-6.dll" "$PREFIX/bin/mpfr-6.dll"
  fi
  mv "$PREFIX/lib/mpfr.dll.lib" "$PREFIX/lib/mpfr.lib"
  test -f "$PREFIX/bin/mpfr-6.dll"
  test -f "$PREFIX/lib/mpfr.lib"
fi
