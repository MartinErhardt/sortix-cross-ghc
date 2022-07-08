#echo "Build ghc: -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
rm -rf ghc
wget -c https://downloads.haskell.org/~ghc/9.2.3/ghc-9.2.3-src.tar.xz
tar -xvf ghc-9.2.3-src.tar.xz
mv ghc-9.2.3 ghc
cd ghc
patch -p0 < ../ghc_patch.diff
./boot &&
./configure --target=x86_64-sortix \
            --with-iconv-libraries=$SORTIX/sysroot/lib \
	    --with-iconv-includes=$SORTIX/sysroot/include &&
           # --with-gmp-libraries=$SORTIX/sysroot/lib \
	   # --with-gmp-includes=$SORTIX/sysroot/include &&
hadrian/build -V -j --flavour=static+no_dynamic_ghc -V -j
