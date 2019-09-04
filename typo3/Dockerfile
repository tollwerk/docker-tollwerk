# Image is based on Tollwerk Base
FROM daigoro.tollwerk.net:8083/tollwerk/base:latest

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Copy the build shell scripts
COPY typo3/scripts /scripts
COPY .shared/config/php.ini /scripts/

# Copy fixture & extension template files
COPY typo3/fixture /fixture
COPY typo3/extension /extension

# Configure Apache for TYPO3
RUN chmod 0755 /scripts/* \
    && /scripts/configure-apache.sh \
    && cp /scripts/bootstrap.sh /bootstrap.sh \
    && rm -rf /scripts

# TYPO3 bootstrapping as entrypoint
ENTRYPOINT ["/bootstrap.sh"]

# Run Apache as the default command
CMD ["httpd", "-D", "FOREGROUND"]
