# Prepare Alpine image for Go installation
FROM golang:alpine as golang

# Install
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk --update --no-cache add git \
    && go get -u github.com/fogleman/primitive

# Image is based on the the latest Alpine image
FROM alpine:edge

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Include primitive
COPY --from=golang /go/bin/primitive /usr/local/bin/primitive

# Copy install scripts & configuration files
COPY php/scripts /scripts
COPY php/config/* /scripts/
COPY .shared/config/php.ini /scripts/

# Install PHP and additional software
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    apk --update --no-cache add \
        bash \
        graphicsmagick \
        nodejs \
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
    && cp /scripts/php.ini /etc/php7/conf.d/50-settings.ini \
    && cp /scripts/php-fpm.conf /etc/php7/php-fpm.conf \
    && chmod 0755 /scripts/* \
    && /scripts/configure.sh \
    && /scripts/install.sh \
    && /scripts/mozjpeg.sh "3.3.1" \
    && /scripts/webp.sh "1.0.3" \
    && /scripts/svgo.sh \
    && /scripts/finalize.sh \
    && rm -rf /var/cache/apk/* /scripts

# Expose port 9000
EXPOSE 9000

# Add default command
CMD ["php-fpm7", "-F"]
