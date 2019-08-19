# Image is based on Tollwerk Base
FROM daigoro.tollwerk.net:8083/tollwerk/base:latest

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Copy the build shell scripts into the container
COPY typo3/scripts /scripts
COPY .shared/config/php.ini /scripts/

# Configure Apache for TYPO3
RUN chmod 0755 /scripts/* \
    && /scripts/configure-apache.sh \
    && /scripts/configure-php.sh \
    && cp /scripts/php.ini /etc/php7/conf.d/50-settings.ini \
    && cp /scripts/bootstrap.sh /bootstrap.sh \
    && rm -rf /var/cache/apk/* /scripts

# TYPO3 bootstrapping as entrypoint
ENTRYPOINT ["/bootstrap.sh"]

# Run Apache as the default command
CMD ["httpd", "-D", "FOREGROUND"]
