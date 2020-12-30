# Image is based on official PHP 7.4 Alpine image
FROM php:7.4-cli-alpine

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Include Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy install scripts
COPY .shared/config/php.ini /scripts/
COPY .shared/scripts/install-php.sh /scripts/
COPY base/scripts/httpd-foreground /usr/local/bin/

# Copy PHP extension installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install PHP and additional software
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/community" >> /etc/apk/repositories \
    && apk --update-cache add ca-certificates \
    && apk add --update-cache \
        apache2 \
        apache2-ctl \
        apache2-http2 \
        apache2-utils \
        apache2-proxy \
        apache2-proxy-html \
        apache2-ssl \
        apache-mod-fcgid \
        libxml2-dev \
        git \
        mysql-client \
        bash \
    && chmod 0755 /scripts/* \
    && chmod +x /usr/local/bin/install-php-extensions /usr/local/bin/httpd-foreground \
    && sync \
    && /scripts/install-php.sh \
    && rm -rf /var/cache/apk/* /scripts /usr/local/bin/install-php-extensions \
    && php -v

# Expose port 80
EXPOSE 80

# Run Apache
CMD ["httpd-foreground"]
