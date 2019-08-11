# Image is based on Tollwerk Base
FROM daigoro.tollwerk.net:8083/tollwerk/base:latest

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Copy the build shell scripts into the container
COPY scripts /scripts

# Configure Apache for TYPO3
RUN /scripts/configure.sh

# TYPO3 bootstrapping as entrypoint
ENTRYPOINT ["/scripts/typo3-bootstrap.sh"]

# Run Apache as the default command
CMD ["httpd", "-D", "FOREGROUND"]
