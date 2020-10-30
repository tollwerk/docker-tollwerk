# Image is based on the official Solr image
FROM solr:latest

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Run commands as root
USER root

# Install Git
RUN apt-get update && \
  apt-get -y install git && \
  rm -rf /var/lib/apt/lists/*

# Run as Solr user
USER $SOLR_USER

COPY solr-ci/scripts/bootstrap.sh /docker-entrypoint-initdb.d/
