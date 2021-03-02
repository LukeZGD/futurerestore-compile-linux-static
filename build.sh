#!/bin/bash

export STATIC_FLAG="--enable-static --disable-shared"
export BEGIN_LDFLAGS="-Wl,--allow-multiple-definition"
export IS_STATIC=1
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig

mkdir ./futurerestore_compile
cd ./futurerestore_compile

set -e

sudo add-apt-repository universe
sudo apt update
sudo apt install -y pkg-config libtool automake g++ python-dev libzip-dev libcurl4-openssl-dev cmake libssl-dev libusb-1.0-0-dev libreadline-dev libbz2-dev libpng-dev git

git clone --recursive https://github.com/lzfse/lzfse
git clone --recursive https://github.com/curl/curl
git clone --recursive https://github.com/libimobiledevice/libplist
git clone --recursive https://github.com/libimobiledevice/libusbmuxd
git clone --recursive https://github.com/libimobiledevice/libimobiledevice
git clone --recursive https://github.com/libimobiledevice/libirecovery
git clone --recursive https://github.com/tihmstar/libgeneral
git clone --recursive https://github.com/tihmstar/libfragmentzip
git clone --recursive https://github.com/tihmstar/img4tool
git clone --recursive https://github.com/marijuanARM/futurerestore

# libgeneral fix
sed -i'' 's|#   include CUSTOM_LOGGING|//#   include CUSTOM_LOGGING|' ./libgeneral/include/libgeneral/macros.h

cd ./lzfse
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

if [ $IS_STATIC == 1 ]; then
    git clone --recursive https://github.com/google/brotli
    cd ./brotli
    autoreconf -fi
    ./configure $STATIC_FLAG
    sudo make install LDFLAGS="$BEGIN_LDFLAGS"
    cd ..

    wget https://ftp.gnu.org/gnu/libunistring/libunistring-0.9.10.tar.gz
    tar -zxvf ./libunistring-0.9.10.tar.gz
    cd ./libunistring-0.9.10
    autoreconf -fi
    ./configure $STATIC_FLAG
    sudo make install LDFLAGS="$BEGIN_LDFLAGS"
    cd ..

    wget https://ftp.gnu.org/gnu/libidn/libidn2-2.3.0.tar.gz
    tar -zxvf ./libidn2-2.3.0.tar.gz
    cd libidn2-2.3.0
    ./configure $STATIC_FLAG
    sudo make install LDFLAGS="$BEGIN_LDFLAGS"
    cd ..

    wget https://github.com/rockdaboot/libpsl/releases/download/0.21.1/libpsl-0.21.1.tar.gz
    tar -zxvf libpsl-0.21.1.tar.gz
    cd libpsl-0.21.1
    ./configure $STATIC_FLAG
    sudo make install LDFLAGS="$BEGIN_LDFLAGS"
    cd ..
fi

# custom curl build with schannel so ssl / https works out of the box on windows
cd ./curl
autoreconf -fi
./configure $STATIC_FLAG --with-schannel --without-ssl
cd lib
if [ $IS_STATIC == 1 ]; then
    sudo make install CFLAGS="-DCURL_STATICLIB -DNGHTTP2_STATICLIB" LDFLAGS="$BEGIN_LDFLAGS"
else
    sudo make install LDFLAGS="$BEGIN_LDFLAGS"
fi
cd ..
cd ..

cd ./libplist
./autogen.sh $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd ./libusbmuxd
./autogen.sh $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd ./libimobiledevice
./autogen.sh $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd ./libirecovery
./autogen.sh $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd ./libgeneral
./autogen.sh $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..


cd ./libfragmentzip
if [ $IS_STATIC == 1 ]; then
    export curl_LIBS="$(curl-config --static-libs)"
fi
./autogen.sh $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd ./img4tool
./autogen.sh $STATIC_FLAG
sudo make install LDFLAGS="$BEGIN_LDFLAGS"
cd ..

cd ./futurerestore
./autogen.sh $STATIC_FLAG

if [ $IS_STATIC == 1 ]; then
    #hacky workaround: replace libgeneral libs to append missing libraries at the end of the g++ command, works because libgeneral is the last lib to be linked
    make CFLAGS="-DCURL_STATICLIB" LDFLAGS="$BEGIN_LDFLAGS" libgeneral_LIBS="-lbcrypt -llzma -lbz2 -liconv -lunistring -lnghttp2"
else
    make LDFLAGS="$BEGIN_LDFLAGS"
fi

sudo make install
cd ..
