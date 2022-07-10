set -e
. setenv.sh
x86_64-sortix-ghc -V || ./build_ghc.sh

#./build_ghc.sh

if ! test -d kell
then
  git clone https://github.com/MartinErhardt/kell.git
fi
mkdir -p $SORTIX/sysroot-overlay/bin
cd kell
cabal build exe:kell --with-ghc=x86_64-sortix-ghc\
  --with-ghc-pkg=x86_64-sortix-ghc-pkg\
  --with-gcc=x86_64-sortix-gcc\
  --with-ld=x86_64-sortix-ld\
  --hsc2hs-options=--cross-compile
cp ./dist-newstyle/build/x86_64-sortix/ghc-9.2.3/kell-0.0.1.0/x/kell/build/kell/kell $SORTIX/sysroot-overlay/bin
echo "Build GMP---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
cd "$SORTIX" &&
make -j20 PACKAGES='grep' HOST=x86_64-sortix sortix.iso
