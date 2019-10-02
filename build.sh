#!/bin/bash -xe

export THREADS=4
export BINUTILS_VERSION=2.31 
export GCC_VERSION=7.4.0 

export PREFIX=$(pwd)/mipsel-unknown-elf

pacman-key --init
pacman-key --populate msys2
pacman-key --refresh-keys
pacman -Sy --noconfirm make texinfo mpfr mpfr-devel isl gmp gmp-devel mpc mpc-devel tar git zip base-devel mingw-w64-i686-gcc mingw-w64-i686-tinyxml2

#Compile binutils
wget http://ftpmirror.gnu.org/binutils/binutils-${BINUTILS_VERSION}.tar.xz
tar -xf binutils-${BINUTILS_VERSION}.tar.xz
rm binutils-${BINUTILS_VERSION}.tar.xz
cd binutils-${BINUTILS_VERSION}
mkdir build
cd build
../configure --prefix=${PREFIX} --target=mipsel-unknown-elf --with-float=soft --disable-nls
make -j ${THREADS}
make install-strip
cd ../..
rm -rf binutils-${BINUTILS_VERSION}

#Compile GCC
wget http://ftpmirror.gnu.org/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz
tar -xf gcc-${GCC_VERSION}.tar.xz
rm gcc-${GCC_VERSION}.tar.xz
cd gcc-${GCC_VERSION}
mkdir build
cd build
../configure --prefix=${PREFIX} --disable-nls --disable-libada --disable-libssp --disable-libquadmath --disable-libstdc++-v3 --target=mipsel-unknown-elf --with-float=soft --enable-languages=c,c++ --with-gnu-as --with-gnu-ld
make -j ${THREADS}
make install-strip
cd ../..
rm -rf gcc-${GCC_VERSION}

echo "__CTOR_LIST__ = .; 
___CTOR_LIST__ = .; 
LONG (((__CTOR_END__ - __CTOR_LIST__) / 4) - 2) 
KEEP (*(SORT (.ctors.*))) 
KEEP (*(.ctors)) 
LONG (0x00000000) 
__CTOR_END__ = .; 
. = ALIGN (0x10); 

__DTOR_LIST__ = .; 
___DTOR_LIST__ = .; 
LONG (((__DTOR_END__ - __DTOR_LIST__) / 4) - 2) 
KEEP (*(SORT (.dtors.*))) 
KEEP (*(.dtors)) 
LONG (0x00000000) 
__DTOR_END__ = .; 
. = ALIGN (0x10);"  >> patch
sed -i -- '/_ftext = \./ r patch' ${PREFIX}/mipsel-unknown-elf/lib/ldscripts/elf32elmip.x
rm patch

git clone --depth 1 https://github.com/Lameguy64/PSn00bSDK.git psn00bsdk
cd psn00bsdk
cd libpsn00b
make -j ${THREADS}
cd ../tools
make -j ${THREADS}
make install

zip toolchain.zip mipsel-unknown-elf psn00bsdk