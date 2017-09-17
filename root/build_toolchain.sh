#!/bin/bash -ex

BUILD_ROOT="/usr/src/build"
PATCHES_ROOT="/usr/src/patches"
SRC_ROOT="/usr/src/sources"

# Download source archives
mkdir -p $BUILD_ROOT/binutils $BUILD_ROOT/gcc $SRC_ROOT
cd /usr/src
wget -nv \
	http://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VER.tar.bz2 \
	http://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.xz \
	http://ftp.gnu.org/gnu/gmp/gmp-$GMP_VER.tar.xz \
	http://isl.gforge.inria.fr/isl-$ISL_VER.tar.xz \
	http://ftp.gnu.org/gnu/mpc/mpc-$MPC_VER.tar.gz \
	http://ftp.gnu.org/gnu/mpfr/mpfr-$MPFR_VER.tar.xz \
	https://dl.lochnair.net/toolchain-patches-SDK-3.1.0p2-build34.tgz

# Extract patches
tar xf toolchain-patches-SDK-3.1.0p2-build34.tgz

# Extract source archives
cd $SRC_ROOT
for file in ../*.tar.*; do tar xf "$file"; done

# Apply Octeon patches for Binutils
cd $SRC_ROOT/binutils-$BINUTILS_VER
for i in {0001..0111}; do
  patch -p1 -i $PATCHES_ROOT/binutils/$i-*
done

# Create symlinks to GCC dependencies
cd $SRC_ROOT/gcc-$GCC_VER
ln -s ../gmp-$GMP_VER gmp
ln -s ../isl-$ISL_VER isl
ln -s ../mpc-$MPC_VER mpc
ln -s ../mpfr-$MPFR_VER mpfr

# Binutils
cd $BUILD_ROOT/binutils
$SRC_ROOT/binutils-$BINUTILS_VER/configure --prefix=/opt/cross --target=mips64-octeon-linux --disable-multilib --disable-werror
make -j$(nproc)
make install

# GCC - stage 1
cd $BUILD_ROOT/gcc
$SRC_ROOT/gcc-$GCC_VER/configure --prefix=/opt/cross --target=mips64-octeon-linux --disable-fixed-point --disable-multilib --disable-sim --enable-languages=c --with-abi=64 --with-float=soft --with-mips-plt
make -j$(nproc) all-gcc
make install-gcc

cd /root

# Cleanup
rm -rf /usr/src
