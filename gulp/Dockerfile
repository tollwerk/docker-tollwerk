# Base this image on the official Node image
FROM node:alpine

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Install packages
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk --update --no-cache add bash git \
    && cd / \
    && mkdir -p /project/docs /project/public /fractal/build /fractal/components \
    && npm install -g gulp-cli \
    && rm -rf /var/cache/apk/*

# Copy pagacke.json
COPY gulp/config/package.json /project/

# Copy templates
COPY gulp/config/*.dist.js /fractal/

# Copy bootstrap file
COPY gulp/scripts/bootstrap.sh /
RUN chmod 0755 /bootstrap.sh

# Set the working directory
WORKDIR /project

# Expose the Fractal port
EXPOSE 3000

# Expose the browsersync port
EXPOSE 3002

# TYPO3 bootstrapping as entrypoint
ENTRYPOINT ["/bootstrap.sh"]

# Run Apache as the default command
CMD ["gulp", "--watch"]
