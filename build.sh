#!/bin/bash
set -x

if [[ -z ${MAKE_J} ]]; then
  MAKE_J=$(grep -c ^processor /proc/cpuinfo)
fi

OPENSSL_VER=1_0_2l
OPENSSL_URL=https://github.com/openssl/openssl/archive/OpenSSL_${OPENSSL_VER}.tar.gz
OPENSSL_SHA256=a3d3a7c03c90ba370405b2d12791598addfcafb1a77ef483c02a317a56c08485

STUNNEL_VER=5.42
STUNNEL_URL=https://www.stunnel.org/downloads/stunnel-${STUNNEL_VER}.tar.gz
STUNNEL_SHA256=1b6a7aea5ca223990bc8bd621fb0846baa4278e1b3e00ff6eee279cb8e540fab

WGET="wget --no-check-certificate --secure-protocol=TLSv1 -T 30 -nv"

export CFLAGS=-fPIC &&\
mkdir /build &&\
cd /build &&\
${WGET} -O openssl.tar.gz ${OPENSSL_URL} &&\
echo "${OPENSSL_SHA256}  openssl.tar.gz" | sha256sum -c - &&\
tar xf openssl.tar.gz &&\
cd openssl-OpenSSL_${OPENSSL_VER} &&\
./config no-shared $CFLAGS &&\
make clean install &&\
cd .. &&\
${WGET} -O stunnel.tar.gz ${STUNNEL_URL} &&\
echo "${STUNNEL_SHA256}  stunnel.tar.gz" | sha256sum -c - &&\
tar xf stunnel.tar.gz && \
cd stunnel-${STUNNEL_VER} && \
export PKG_CONFIG_PATH="/usr/local/ssl/lib/pkgconfig:/usr/local/lib/pkgconfig" &&\
export PKG_CONFIG="pkg-config --static" &&\
export LDFLAGS="-static-libgcc -static-libstdc++" &&\
./configure --enable-static=yes --enable-shared=no &&\
make clean install -j${MAKE_J} &&\
cd / &&\
rm -rf /build
