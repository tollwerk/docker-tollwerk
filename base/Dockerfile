# Image is based on Alpine Apache
FROM httpd:2.4-alpine

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Include Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Copy install scripts
COPY .shared/config/php.ini /scripts/
COPY .shared/scripts/install-php.sh /scripts/

# Install PHP and additional software
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk --update --no-cache add \
        git \
        mysql-client \
    && chmod 0755 /scripts/* \
    && /scripts/install-php.sh \
    && rm -rf /var/cache/apk/* /scripts

# Expose port 80
EXPOSE 80
