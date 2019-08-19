#!/bin/bash

## Disable opcache on php 7.3 since that triggers segfaults 'zend_mm_heap corrupted' with vfsStream 1.6.4 (currently)
## Note: Still true?
echo "opcache.enable_cli = 0" >> /etc/php7/conf.d/00_opcache.ini

# Configure Phar
echo "phar.readonly = Off" >> /etc/php7/conf.d/01_phar.ini;

# Configure XDebug
echo "xdebug.max_nesting_level = 400" >> /etc/php7/conf.d/xdebug.ini
