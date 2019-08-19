#!/bin/bash

# Remove temporary tools
apk del \
  autoconf \
  automake \
  gcc \
  g++ \
  giflib \
  giflib-dev \
  libtool \
  libjpeg-turbo \
  libjpeg-turbo-dev \
  libpng \
  libpng-dev \
  make \
  pkgconf \
  nasm \
  npm \
  sdl-dev;

# Cleanup
rm -rf /var/cache/apk/*;
