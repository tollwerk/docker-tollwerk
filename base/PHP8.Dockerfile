# Image is based on official PHP 8.0 Alpine image
FROM php:8.0-cli-alpine

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Include Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy install scripts
COPY base/scripts /scripts
COPY .shared/config/php.ini /scripts/

# Copy PHP extension installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install PHP and additional software
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/community" >> /etc/apk/repositories \
    && apk add --update-cache \
        apache2 \
        apache2-ctl \
        apache2-http2 \
        apache2-utils \
        apache2-proxy \
        apache2-proxy-html \
        apache2-ssl \
        apache-mod-fcgid \
        ca-certificates \
        libxml2-dev \
        git \
        mysql-client \
        bash \
    && chmod 0755 /scripts/* \
    && chmod +x /usr/local/bin/install-php-extensions \
    && sync \
    && /scripts/install-php8.sh \
    && php -v \
    && rm -rf /var/cache/apk/* /scripts /usr/local/bin/install-php-extensions

# Expose port 80
EXPOSE 80

# Run Apache as the default command
CMD ["httpd", "-D", "FOREGROUND"]
