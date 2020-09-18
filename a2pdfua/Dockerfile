# Image is based on Ant base
FROM hub.tollwerk.net/tollwerk/ant:latest as fop

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Copy patches
COPY a2pdfua/patches /patches

# Build custom FOP
ENV FOP_VERSION 2_5
RUN mkdir -p /usr/local/src && \
    cd /usr/local/src && \
    wget -q https://github.com/apache/xmlgraphics-fop/archive/fop-${FOP_VERSION}.tar.gz && \
    tar -xzf fop-${FOP_VERSION}.tar.gz && \
    apk --update --no-cache add patch && \
    patch -p0 -i /patches/0001-Footnote-ID.patch && \
    cd xmlgraphics-fop-fop-${FOP_VERSION} && \
    /opt/ant/bin/ant -buildfile fop/build.xml

# Image is based on the the latest Alpine image
FROM alpine:latest as packager
RUN apk --update --no-cache add openjdk11-jdk openjdk11-jmods
ENV JAVA_MINIMAL="/opt/java-minimal"

# build minimal JRE
RUN /usr/lib/jvm/java-11-openjdk/bin/jlink \
    --verbose \
    --add-modules java.base,java.desktop,java.xml \
    --compress 2 --strip-debug --no-header-files --no-man-pages \
    --release-info="add:IMPLEMENTOR=tollwerk:IMPLEMENTOR_VERSION=tollwerk_JRE" \
    --output "$JAVA_MINIMAL"

#    java.base,java.sql,java.naming,java.desktop,java.management,java.security.jgss,java.instrument \

# Image is based on the the latest Alpine image
FROM alpine:latest
ENV FOP_VERSION=2_5
ENV JAVA_HOME=/opt/java-minimal
ENV PATH="$PATH:$JAVA_HOME/bin"
ENV FOP_HOME="/fop"

# Maintainer
LABEL maintainer="tollwerk GmbH <info@tollwerk.de>"

# Include Java
COPY --from=packager "$JAVA_HOME" "$JAVA_HOME"

# Include custom FOP
COPY --from=fop /usr/local/src/xmlgraphics-fop-fop-${FOP_VERSION}/fop/fop /usr/local/bin/fop

# Install AsciiDoc & DocBook XSL
RUN mkdir /fop && \
    apk --update --no-cache add lcms2 freetype bash asciidoc docbook-xsl ttf-dejavu

# Include custom FOP libs
COPY --from=fop /usr/local/src/xmlgraphics-fop-fop-${FOP_VERSION}/fop /fop

# Copy scripts & themes
COPY a2pdfua/scripts /scripts
COPY a2pdfua/themes /themes

# Expect build code to be mounted to /src
WORKDIR "/project"

# Ant as entrypoint
ENTRYPOINT ["/scripts/adoc2pdfua.sh"]
