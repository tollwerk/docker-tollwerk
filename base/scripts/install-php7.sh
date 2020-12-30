#!/bin/bash

# Install PHP extenions
install-php-extensions apcu \
    bcmath \
    bz2 \
    gd \
    imap \
    intl \
    mcrypt \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    soap \
    tidy \
    xdebug \
    xsl \
    zip

# Configure PHP
cp /scripts/php.ini /usr/local/etc/php/conf.d/docker-php-settings.ini

## Disable opcache on php 7.3 since that triggers segfaults 'zend_mm_heap corrupted' with vfsStream 1.6.4 (currently)
## Note: Still true?
echo "opcache.enable_cli = 0" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# Configure Phar
echo "phar.readonly = Off" >> /usr/local/etc/php/conf.d/docker-php-ext-phar.ini

# Configure XDebug
echo "xdebug.max_nesting_level = 400" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
