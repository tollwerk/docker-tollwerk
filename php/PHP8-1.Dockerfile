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

# Add locale support
ENV MUSL_LOCALE_DEPS cmake make musl-dev gcc gettext-dev libintl
ENV MUSL_LOCPATH /usr/share/i18n/locales/musl
RUN apk add --no-cache \
    $MUSL_LOCALE_DEPS \
    && wget https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip \
    && unzip musl-locales-master.zip \
      && cd musl-locales-master \
      && cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr . && make && make install \
      && cd .. && rm -r musl-locales-master

# Install PHP and additional software
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && mkdir /www \
    && chmod 0755 /scripts/* \
    && apk --update --no-cache add bash \
    && /scripts/install.sh \
    && /scripts/install-php81.sh \
    && /scripts/mozjpeg.sh "3.3.1" \
    && /scripts/webp.sh "1.0" \
    && /scripts/svgo.sh \
    && /scripts/finalize.sh \
    && mv /scripts/setup-ssmtp.sh /usr/local/bin \
    && rm -rf /var/cache/apk/* /scripts

# Expose port 9000
EXPOSE 9000

# Add default command
CMD ["php-fpm81", "-F"]

# https://github.com/ChrisB9/php8-xdebug/blob/main/php-dev-8.dockerfile
# https://github.com/eko/docker-symfony/blob/master/php-fpm/Dockerfile
