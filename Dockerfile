# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

ARG OL_BASE=container-registry.oracle.com/os/oraclelinux:8-slim
FROM ${OL_BASE}

# Note: If you are behind a web proxy, set the build variables for the build:
#       E.g.:  docker build --build-arg "https_proxy=..." --build-arg "http_proxy=..." --build-arg "no_proxy=..." ...
LABEL \
    org.opencontainers.image.url='https://github.com/graalvm/container' \
    org.opencontainers.image.source='https://github.com/graalvm/container/tree/master/community' \
    org.opencontainers.image.title='GraalVM Community Edition' \
    org.opencontainers.image.authors='GraalVM Sustaining Team <graalvm-sustaining_ww_grp@oracle.com>' \
    org.opencontainers.image.description='GraalVM is a universal virtual machine for running applications written in JavaScript, Python, Ruby, R, JVM-based languages like Java, Scala, Clojure, Kotlin, and LLVM-based languages such as C and C++.'
    
RUN microdnf update -y oraclelinux-release-el8 \
    && microdnf --enablerepo ol8_codeready_builder install bzip2-devel ed gcc gcc-c++ gcc-gfortran gzip file fontconfig less libcurl-devel make openssl openssl-devel readline-devel tar glibc-langpack-en \
    vi which xz-devel zlib-devel findutils glibc-static libstdc++ libstdc++-devel libstdc++-static zlib-static \
    && microdnf clean all

RUN fc-cache -f -v

ARG GRAALVM_VERSION=21.3.0
ARG JAVA_VERSION=java11
ARG GRAALVM_PKG=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-$GRAALVM_VERSION/graalvm-ce-$JAVA_VERSION-GRAALVM_ARCH-$GRAALVM_VERSION.tar.gz
ARG TARGETPLATFORM

ENV LANG=en_US.UTF-8 \
    JAVA_HOME=/opt/graalvm-ce-$JAVA_VERSION-$GRAALVM_VERSION/

ADD gu-wrapper.sh /usr/local/bin/gu
RUN set -eux \
    && if [ "$TARGETPLATFORM" == "linux/amd64" ]; then GRAALVM_PKG=${GRAALVM_PKG/GRAALVM_ARCH/linux-amd64}; fi \
    && if [ "$TARGETPLATFORM" == "linux/arm64" ]; then GRAALVM_PKG=${GRAALVM_PKG/GRAALVM_ARCH/linux-aarch64}; fi \
    && curl --fail --silent --location --retry 3 ${GRAALVM_PKG} \
    | gunzip | tar x -C /opt/ \

    # Set alternative links
    && mkdir -p "/usr/java" \
    && ln -sfT "$JAVA_HOME" /usr/java/default \
    && ln -sfT "$JAVA_HOME" /usr/java/latest \
    && for bin in "$JAVA_HOME/bin/"*; do \
    base="$(basename "$bin")"; \
    [ ! -e "/usr/bin/$base" ]; \
    alternatives --install "/usr/bin/$base" "$base" "$bin" 20000; \
    done \

    && chmod +x /usr/local/bin/gu

# RUN microdnf install -y zip
# RUN /usr/local/bin/gu install native-image
# RUN curl -4 -L https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie -o /usr/bin/aws-lambda-rie
# RUN chmod 755 /usr/bin/aws-lambda-rie

CMD java -version
