# Image is based on Alpine OpenJDK
FROM maven:3-jdk-8-alpine

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Installs Ant
ENV ANT_VERSION 1.10.8
RUN cd && \
    wget -q https://downloads.apache.org/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
    tar -xzf apache-ant-${ANT_VERSION}-bin.tar.gz && \
    mv apache-ant-${ANT_VERSION} /opt/ant && \
    rm apache-ant-${ANT_VERSION}-bin.tar.gz
ENV ANT_HOME /opt/ant
ENV PATH ${PATH}:/opt/ant/bin

# Expect build code to be mounted to /src
WORKDIR "/src"

# Ant as entrypoint
ENTRYPOINT ["/opt/ant/bin/ant"]
