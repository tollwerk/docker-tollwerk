#!/bin/bash

# Install PHP
apk --update --no-cache add \
    php8 \
    php8-bcmath \
    php8-bz2 \
    php8-dom \
    php8-ctype \
    php8-curl \
    php8-fileinfo \
    php8-fpm \
    php8-gd \
    php8-iconv \
    php8-imap \
    php8-intl \
    php8-json \
    php8-mbstring \
    php8-mysqli \
    php8-opcache \
    php8-openssl \
    php8-pcntl \
    php8-pecl-xdebug \
    php8-pdo \
    php8-pdo_mysql \
    php8-phar \
    php8-posix \
    php8-simplexml \
    php8-session \
    php8-soap \
    php8-tidy \
    php8-tokenizer \
    php8-xml \
    php8-xmlreader \
    php8-xmlwriter \
    php8-xsl \
    php8-zip

# Configure PHP
cp /scripts/php.ini /etc/php8/conf.d/50-settings.ini
cp /scripts/php-fpm.conf /etc/php8/php-fpm.conf

## Disable opcache on php 7.3 since that triggers segfaults 'zend_mm_heap corrupted' with vfsStream 1.6.4 (currently)
## Note: Still true?
echo "opcache.enable_cli = 0" >>/etc/php8/conf.d/00_opcache.ini

# Configure Phar
echo "phar.readonly = Off" >>/etc/php8/conf.d/01_phar.ini

# Configure XDebug
echo "zend_extension=xdebug.so" >>/etc/php8/conf.d/50_xdebug.ini
echo "xdebug.mode=develop,coverage" >>/etc/php8/conf.d/50_xdebug.ini
echo "xdebug.max_nesting_level = 400" >>/etc/php8/conf.d/50_xdebug.ini

# Symlink PHP CLI
ln -s /usr/bin/php8 /usr/bin/php
