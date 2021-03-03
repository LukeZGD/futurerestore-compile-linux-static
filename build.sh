#!/bin/bash

export STATIC_FLAG="--enable-static --disable-shared"
export BEGIN_LDFLAGS="-Wl,--allow-multiple-definition"
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig

rm -rf futurerestore_compile
mkdir futurerestore_compile
cd futurerestore_compile

set -e

sudo add-apt-repository universe
sudo apt update
sudo apt install -y pkg-config libtool automake g++ python-dev cmake libssl-dev libusb-1.0-0-dev libreadline-dev libpng-dev git autopoint aria2

git clone https://github.com/lzfse/lzfse
git clone https://github.com/libimobiledevice/libplist
git clone https://github.com/libimobiledevice/libusbmuxd
git clone https://github.com/libimobiledevice/libimobiledevice
git clone https://github.com/libimobiledevice/libirecovery
git clone https://github.com/tihmstar/libgeneral
git clone https://github.com/tihmstar/libfragmentzip
git clone https://github.com/tihmstar/img4tool
git clone --recursive https://github.com/marijuanARM/futurerestore
git clone https://github.com/madler/zlib
git clone https://github.com/curl/curl
aria2c https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
aria2c https://tukaani.org/xz/xz-5.2.4.tar.gz
aria2c https://libzip.org/download/libzip-1.5.1.tar.gz

# libgeneral fix
sed -i'' 's|#   include CUSTOM_LOGGING|//#   include CUSTOM_LOGGING|' libgeneral/include/libgeneral/macros.h

cd lzfse
make LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
cd ..

tar -zxvf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8
make LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
cd ..

cd zlib
./configure --static
make LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
cd ..

tar -zxvf xz-5.2.4.tar.gz
cd xz-5.2.4
./autogen.sh
./configure $STATIC_FLAG
make LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
cd ..

tar -zxvf libzip-1.5.1.tar.gz
cd libzip-1.5.1
mkdir build
cd build
cmake .. -DBUILD_SHARED_LIBS=OFF
make LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
cd ../..

cd curl
autoreconf -fi
./configure $STATIC_FLAG
make CFLAGS="-DCURL_STATICLIB" LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
sudo ln -sf /usr/local/lib/libcurl.a /usr/lib/x86_64-linux-gnu
sudo ln -sf /usr/local/lib/libcurl.la /usr/lib/x86_64-linux-gnu
sudo ln -sf /usr/local/lib/pkgconfig/libcurl.pc /usr/lib/x86_64-linux-gnu/pkgconfig
cd ..

cd libplist
./autogen.sh $STATIC_FLAG --without-cython
make LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
cd ..

cd libusbmuxd
./autogen.sh $STATIC_FLAG
make LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
cd ..

cd libimobiledevice
./autogen.sh $STATIC_FLAG --without-cython
make LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
cd ..

cd libirecovery
./autogen.sh $STATIC_FLAG
make LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
cd ..

cd libgeneral
./autogen.sh $STATIC_FLAG
make LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
cd ..

cd libfragmentzip
./autogen.sh $STATIC_FLAG
make LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
cd ..

cd img4tool
./autogen.sh $STATIC_FLAG
make LDFLAGS="$BEGIN_LDFLAGS"
sudo make install
cd ..

cd futurerestore
./autogen.sh
make CFLAGS="-DCURL_STATICLIB" LDFLAGS="$BEGIN_LDFLAGS" libgeneral_LIBS="-llzma -lbz2"
sudo make install
cd ..
