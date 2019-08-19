# Image is based on Alpine Apache
FROM httpd:2.4-alpine

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Include Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install PHP and additional software
RUN apk --update --no-cache add \
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
        php7-tokenizer \
        php7-xml \
        php7-xmlreader \
        php7-xmlwriter \
        php7-xdebug \
        php7-xsl \
        php7-zip \
    && rm -rf /var/cache/apk/*

# Expose port 80
EXPOSE 80
