#!/bin/bash

# Install PHP
apk --update --no-cache add \
    php81 \
    php81-bcmath \
    php81-bz2 \
    php81-dom \
    php81-ctype \
    php81-curl \
    php81-fileinfo \
    php81-fpm \
    php81-gd \
    php81-iconv \
    php81-imap \
    php81-intl \
    php81-json \
    php81-mbstring \
    php81-mysqli \
    php81-opcache \
    php81-openssl \
    php81-pcntl \
    php81-pecl-xdebug \
    php81-pdo \
    php81-pdo_mysql \
    php81-phar \
    php81-posix \
    php81-simplexml \
    php81-session \
    php81-soap \
    php81-sodium \
    php81-tokenizer \
    php81-xml \
    php81-xmlreader \
    php81-xmlwriter \
    php81-xsl \
    php81-zip
#        php81-tidy \

# Configure PHP
cp /scripts/php.ini /etc/php81/conf.d/50-settings.ini
cp /scripts/php-fpm.conf /etc/php81/php-fpm.conf

## Disable opcache on php 7.3 since that triggers segfaults 'zend_mm_heap corrupted' with vfsStream 1.6.4 (currently)
## Note: Still true?
echo "opcache.enable_cli = 0" >>/etc/php81/conf.d/00_opcache.ini

# Configure Phar
echo "phar.readonly = Off" >>/etc/php81/conf.d/01_phar.ini

# Configure XDebug
echo "zend_extension=xdebug.so" >>/etc/php81/conf.d/50_xdebug.ini
echo "xdebug.mode=develop,coverage" >>/etc/php81/conf.d/50_xdebug.ini
echo "xdebug.max_nesting_level = 400" >>/etc/php81/conf.d/50_xdebug.ini

# Symlink PHP CLI
ln -s /usr/bin/php81 /usr/bin/php
