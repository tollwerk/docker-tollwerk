# Image is based on Tollwerk PHP
FROM hub.tollwerk.net/tollwerk/php:7.4

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Include Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Laravel Envoy
RUN composer global require phpmd/phpmd squizlabs/php_codesniffer sebastian/phpcpd

# Install SSH client & configure PHP
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk --update --no-cache add openssh-client mysql-client nodejs npm rsync git \
        autoconf automake g++ libc6-compat libjpeg-turbo-dev libpng-dev make nasm libtool asciidoctor \
    && echo 'zend_extension=xdebug.so' >> '/etc/php7/conf.d/xdebug.ini' \
    && rm -rf /var/cache/apk/*

# Install the Gulp CLI tool
RUN npm install --global gulp-cli