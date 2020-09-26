# Image is based on Tollwerk PHP
FROM hub.tollwerk.net/tollwerk/php:latest

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Include Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install Laravel Envoy
RUN composer global require "laravel/envoy=~1.0"

# Install SSH client & configure PHP
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk --update --no-cache add openssh-client \
    && echo 'zend_extension=xdebug.so' >> '/etc/php7/conf.d/xdebug.ini' \
    && rm -rf /var/cache/apk/*
