set -e
git clone https://gitlab.com/sortix/sortix.git
. ./setenv.sh

cd $SORTIX && 
make PREFIX="$CROSS_PREFIX" clean-build-tools && 
make PREFIX="$CROSS_PREFIX" build-tools && 
make PREFIX="$CROSS_PREFIX" install-build-tools && 
make distclean
make sysroot-base-headers HOST=$SORTIX_PLATFORM
echo $PATH

ls -la $CROSS_PREFIX/bin $CROSS_PREFIX/sbin

cd ..

wget -c https://sortix.org/toolchain/sortix-binutils-latest.tar.xz
tar -xf sortix-binutils-latest.tar.xz

wget -c https://sortix.org/toolchain/sortix-gcc-latest.tar.xz
tar -xf sortix-gcc-latest.tar.xz

BINUTILS_SRC=$PWD/sortix-binutils-1.1-rc3
GCC_SRC=$PWD/sortix-gcc-1.1-rc3

mkdir -p binutils-build && 
  cd    binutils-build && 
  $BINUTILS_SRC/configure \
  --target=$SORTIX_PLATFORM \
  --with-sysroot="$SORTIX/sysroot" \
  --prefix="$CROSS_PREFIX" \
  --disable-werror &&
make -j20 &&
make install
echo "Build gcc!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
# exit 0
cd ..
mkdir -p gcc-build && 
cd gcc-build && 
$GCC_SRC/configure \
 --target=$SORTIX_PLATFORM \
 --with-sysroot="$SORTIX/sysroot" \
 --prefix="$CROSS_PREFIX" \
 --enable-languages=c,c++ && 
make -j20 all-gcc all-target-libgcc && 
make install-gcc install-target-libgcc
cd ..
cd "$SORTIX" &&
make -j20 PACKAGES='libgmp! libiconv!' HOST=x86_64-sortix

cd ..
ghc/_build/ghc-stage1 -V || ./build_ghc.sh
ghc/_build/ghc-stage1 helloworld.hs 
mkdir -p $SORTIX/sysroot-overlay/bin
cp helloworld $SORTIX/sysroot-overlay/bin

echo "Build GMP---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
cd "$SORTIX" &&
make -j20 PACKAGES='' HOST=x86_64-sortix sortix.iso
