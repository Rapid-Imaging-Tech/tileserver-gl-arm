FROM ubuntu:18.04

EXPOSE 80
VOLUME /data
WORKDIR /data
ENTRYPOINT ["/bin/bash", "-i", "/usr/src/app/run.sh"]

RUN apt-get -qq update \
&& DEBIAN_FRONTEND=noninteractive apt-get -y install \
    apt-transport-https \
    curl \
    unzip \
    build-essential \
    python \
    libcairo2-dev \
    libgles2-mesa-dev \
    libgbm-dev \
    libllvm3.9 \
    libprotobuf-dev \
    libxxf86vm-dev \
    xvfb \
    git \
    zlib1g-dev automake \
    libtool xutils-dev make cmake cmake-data \
    pkg-config python-pip \
    libcurl4-openssl-dev libpng-dev libsqlite3-dev \
    ninja-build \
    libxi-dev libglu1-mesa-dev x11proto-randr-dev \
    x11proto-xext-dev libxrandr-dev \
    x11proto-xf86vidmode-dev libxxf86vm-dev \
    libxcursor-dev libxinerama-dev \
    ccache \
    libjpeg-turbo8 libjpeg-turbo8-dev \
    libuv1-dev \
&& apt-get clean

COPY / /root/

RUN /root/build.bash

