set -e
if ! test -d sortix
then
  git clone https://gitlab.com/sortix/sortix.git
fi
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
if ! x86_64-sortix-ld -V
then
  mkdir -p binutils-build && 
    cd    binutils-build && 
      $BINUTILS_SRC/configure \
      --target=$SORTIX_PLATFORM \
      --with-sysroot="$SORTIX/sysroot" \
      --prefix="$CROSS_PREFIX" \
      --disable-werror &&
    make -j20 &&
    make install
  cd ..
fi

echo "Build gcc!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
if ! x86_64-sortix-gcc -V
then
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
fi

cd "$SORTIX" &&
make -j20 PACKAGES='libgmp! libiconv!' HOST=x86_64-sortix

cd ..
./ccrosskell.sh
