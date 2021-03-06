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
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && mkdir /www \
    && chmod 0755 /scripts/* \
    && apk --update --no-cache add bash \
    && /scripts/install.sh \
    && /scripts/install-php7.sh \
    && /scripts/mozjpeg.sh "3.3.1" \
    && /scripts/webp.sh "1.0.3" \
    && /scripts/svgo.sh \
    && /scripts/finalize.sh \
    && rm -rf /var/cache/apk/* /scripts

# Expose port 9000
EXPOSE 9000

# Add default command
CMD ["php-fpm7", "-F"]
