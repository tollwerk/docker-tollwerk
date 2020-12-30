#!/bin/bash

# Install PHP
apk --update --no-cache add \
    php7 \
    php7-apcu \
    php7-bcmath \
    php7-bz2 \
    php7-dom \
    php7-ctype \
    php7-curl \
    php7-fileinfo \
    php7-fpm \
    php7-gd \
    php7-iconv \
    php7-imap \
    php7-intl \
    php7-json \
    php7-mbstring \
    php7-mcrypt \
    php7-mysqli \
    php7-opcache \
    php7-openssl \
    php7-pcntl \
    php7-pdo \
    php7-pdo_mysql \
    php7-phar \
    php7-posix \
    php7-simplexml \
    php7-session \
    php7-soap \
    php7-tidy \
    php7-tokenizer \
    php7-xml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-xdebug \
    php7-xsl \
    php7-zip

# Configure PHP
cp /scripts/php.ini /etc/php7/conf.d/50-settings.ini
cp /scripts/php-fpm.conf /etc/php7/php-fpm.conf

## Disable opcache on php 7.3 since that triggers segfaults 'zend_mm_heap corrupted' with vfsStream 1.6.4 (currently)
## Note: Still true?
echo "opcache.enable_cli = 0" >>/etc/php7/conf.d/00_opcache.ini

# Configure Phar
echo "phar.readonly = Off" >>/etc/php7/conf.d/01_phar.ini

# Configure XDebug
echo "xdebug.max_nesting_level = 400" >>/etc/php7/conf.d/xdebug.ini
