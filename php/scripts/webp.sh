#!/bin/bash

VERSION="$1";

# Download and install the webp encoder
cd /usr/local;
wget -c https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-$VERSION.tar.gz -O /usr/local/webp.tar.gz;
tar -xf /usr/local/webp.tar.gz;
cd /usr/local/libwebp-$VERSION;
./configure;
make;
make install;
rm -Rf /usr/local/webp.tar.gz /usr/local/libwebp-$VERSION;
