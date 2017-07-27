#!/bin/bash
set -x

if [[ -z ${MAKE_J} ]]; then
  MAKE_J=$(grep -c ^processor /proc/cpuinfo)
fi

ZLIB_VER=1.2.11
ZLIB_URL=http://zlib.net/zlib-${ZLIB_VER}.tar.gz
ZLIB_SHA256=c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1

OPENSSL_VER=1_0_2l
OPENSSL_URL=https://github.com/openssl/openssl/archive/OpenSSL_${OPENSSL_VER}.tar.gz
OPENSSL_SHA256=a3d3a7c03c90ba370405b2d12791598addfcafb1a77ef483c02a317a56c08485

STUNNEL_VER=5.42
STUNNEL_URL=https://www.stunnel.org/downloads/stunnel-${STUNNEL_VER}.tar.gz
STUNNEL_SHA256=1b6a7aea5ca223990bc8bd621fb0846baa4278e1b3e00ff6eee279cb8e540fab

WGET="wget --no-check-certificate --secure-protocol=TLSv1 -T 30 -nv"

mkdir /build &&\
cd /build &&\
${WGET} -O zlib.tar.gz ${ZLIB_URL} &&\
echo "$ZLIB_SHA256  zlib.tar.gz" | sha256sum -c - &&\
tar xf zlib.tar.gz &&\
cd zlib-${ZLIB_VER} &&\
./configure --static &&\
make clean install -j${MAKE_J} &&\
cd .. &&\
${WGET} -O openssl.tar.gz ${OPENSSL_URL} &&\
echo "${OPENSSL_SHA256}  openssl.tar.gz" | sha256sum -c - &&\
tar xf openssl.tar.gz &&\
cd openssl-OpenSSL_${OPENSSL_VER} &&\
./config zlib no-shared &&\
make clean install &&\
cd .. &&\
${WGET} -O stunnel.tar.gz ${STUNNEL_URL} &&\
echo "${STUNNEL_SHA256}  stunnel.tar.gz" | sha256sum -c - &&\
tar xf stunnel.tar.gz && \
cd stunnel-${STUNNEL_VER} && \
export PKG_CONFIG_PATH="/usr/local/ssl/lib/pkgconfig:/usr/local/lib/pkgconfig" &&\
export PKG_CONFIG="pkg-config --static" &&\
export LDFLAGS="-static-libgcc -static-libstdc++ -static" &&\
./configure --enable-static=yes --enable-shared=no
make clean install -j${MAKE_J} &&\
cd / &&\
rm -rf /build
