#!/bin/bash

export STATIC_FLAG="--enable-static --disable-shared"
export BEGIN_LDFLAGS="-Wl,--allow-multiple-definition"
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig

mkdir futurerestore_compile
cd futurerestore_compile

sudo add-apt-repository universe
sudo apt update
sudo apt install -y pkg-config libtool automake g++ python-dev libzip-dev libcurl4-openssl-dev cmake libssl-dev libusb-1.0-0-dev libreadline-dev libbz2-dev libpng-dev git autopoint aria2

git clone https://github.com/lzfse/lzfse
git clone https://github.com/libimobiledevice/libplist
git clone https://github.com/libimobiledevice/libusbmuxd
git clone https://github.com/libimobiledevice/libimobiledevice
git clone https://github.com/libimobiledevice/libirecovery
git clone https://github.com/tihmstar/libgeneral
git clone https://github.com/tihmstar/libfragmentzip
git clone https://github.com/tihmstar/img4tool
git clone https://github.com/madler/zlib
git clone --recursive https://github.com/marijuanARM/futurerestore
aria2c https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
aria2c https://tukaani.org/xz/xz-5.2.4.tar.gz
aria2c https://libzip.org/download/libzip-1.5.1.tar.gz

# libgeneral fix
sed -i'' 's|#   include CUSTOM_LOGGING|//#   include CUSTOM_LOGGING|' libgeneral/include/libgeneral/macros.h

cd lzfse
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd libplist
./autogen.sh $STATIC_FLAG --without-cython
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd libusbmuxd
./autogen.sh $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd libimobiledevice
./autogen.sh $STATIC_FLAG --without-cython
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd libirecovery
./autogen.sh $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd libgeneral
./autogen.sh $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd libfragmentzip
./autogen.sh $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd img4tool
./autogen.sh $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

tar -zxvf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8
make
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd zlib
./configure --static
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

tar -zxvf xz-5.2.4.tar.gz
cd xz-5.2.4
./autogen.sh
./configure $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

tar -zxvf libzip-1.5.1.tar.gz
cd libzip-1.5.1
mkdir build
cd build
cmake .. -DBUILD_SHARED_LIBS=OFF
make
sudo make install
cd ../..

cd futurerestore
./autogen.sh
make LDFLAGS="$BEGIN_LDFLAGS" libgeneral_LIBS="-llzma -lbz2"
sudo make install
cd ..
