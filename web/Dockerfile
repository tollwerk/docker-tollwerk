# Image is based on Tollwerk Base
FROM hub.tollwerk.net/tollwerk/base:latest

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Copy the build shell scripts
COPY web/scripts /scripts
COPY .shared/scripts/configure-apache.sh /scripts/
COPY .shared/config/php.ini /scripts/

# Configure Apache for TYPO3
RUN chmod 0755 /scripts/* \
    && /scripts/configure-apache.sh \
    && ln -s /scripts/bootstrap.sh /bootstrap.sh

# TYPO3 bootstrapping as entrypoint
ENTRYPOINT ["/bootstrap.sh"]

# Run Apache as the default command
CMD ["httpd", "-D", "FOREGROUND"]
