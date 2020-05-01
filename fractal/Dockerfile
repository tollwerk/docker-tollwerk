# Base this image on the official Node image
FROM node:alpine

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Copy pagacke json
COPY fractal/config/* /

# Install packages
RUN apk add git \
    && cd / \
    && mkdir -p /fractal/components /fractal/web /fractal/docs \
    && npm install \
    && npm install -g @frctl/fractal

# Set the working directory
WORKDIR /

# Expose the Fractal port
EXPOSE 3000

# Set the entrypoint
ENTRYPOINT ["fractal", "start"]
