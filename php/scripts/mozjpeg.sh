#!/bin/bash

VERSION="$1"

# Download and install mozjpeg
cd /usr/local
wget -c https://github.com/mozilla/mozjpeg/archive/v$VERSION.tar.gz -O /usr/local/mozjpeg.tar.gz
tar -xf /usr/local/mozjpeg.tar.gz
cd /usr/local/mozjpeg-$VERSION
autoreconf -fiv
mkdir /usr/local/mozjpeg-$VERSION/build
cd /usr/local/mozjpeg-$VERSION/build
../configure
make
make install
ln -s /opt/mozjpeg/bin/jpegtran /usr/local/bin/mozjpeg
rm -Rf /usr/local/mozjpeg.tar.gz /usr/local/mozjpeg-$VERSION
