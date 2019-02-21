FROM ubuntu:18.04 as builder

WORKDIR /root

RUN rm /bin/sh \
&& ln -s /bin/bash /bin/sh \
&& apt-get -qq update \
&& DEBIAN_FRONTEND=noninteractive apt-get -y install \
    apt-transport-https \
    curl \
    wget \
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

# initialize the submodules
RUN cd $HOME \
&& git submodule init \
&& git submodule update \
&& mkdir /root/tileserver-gl/.nvm

ENV NODE_VERSION 6.15.1
ENV NVM_DIR /root/tileserver-gl/.nvm

RUN cd $HOME \
&& curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash \
&& source $NVM_DIR/nvm.sh \
&& nvm alias default $NODE_VERSION \
&& nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# build mapbox-gl-native
RUN cd $HOME/mapbox-gl-native \
&& git checkout arm-64-build \
&& cp /usr/bin/ninja platform/linux/ \
&& cd $HOME/mapbox-gl-native \
&& make node

# installs tileserver-gl WITHOUT the mapbox-gl-native
RUN cd $HOME/tileserver-gl \
&& git checkout arm-64-build \
&& npm install --build-from-source

# copy the stuff we need from mapbox-gl-native
RUN mkdir -p $HOME/tileserver-gl/node_modules/@mapbox/mapbox-gl-native \
&& mv $HOME/mapbox-gl-native/lib/ $HOME/tileserver-gl/node_modules/@mapbox/mapbox-gl-native/ \
&& mkdir -p $HOME/tileserver-gl/node_modules/@mapbox/mapbox-gl-native/platform/node \
&& cp $HOME/mapbox-gl-native/platform/node/index.js $HOME/tileserver-gl/node_modules/@mapbox/mapbox-gl-native/platform/node/ \
&& cp $HOME/mapbox-gl-native/package.json $HOME/tileserver-gl/node_modules/@mapbox/mapbox-gl-native/

# install tileserver-gl-styles
RUN cd $HOME/tileserver-gl-styles \
&& git checkout master && node publish.js \
&& cd $HOME \
&& mv tileserver-gl-styles/ tileserver-gl/node_modules/

RUN rm -rf .git


FROM ubuntu:18.04

ENV NODE_ENV="production"
ENV NODE_VERSION 6.15.1
VOLUME /data
WORKDIR /data
EXPOSE 80
ENTRYPOINT ["/bin/bash", "-i", "/usr/src/app/run.sh"]

RUN rm /bin/sh \
&& ln -s /bin/bash /bin/sh \
&& mkdir -p /usr/src \
&& apt-get -qq update \
&& DEBIAN_FRONTEND=noninteractive apt-get -y install \
    apt-transport-https \
    curl \
    unzip \
#    build-essential \
    python \
#    libcairo2-dev \
#    libgles2-mesa-dev \
#    libgbm-dev \
    libllvm3.9 \
#    libprotobuf-dev \
#    libxxf86vm-dev \
    xvfb \
&& apt-get clean

COPY --from=builder /root/tileserver-gl /usr/src/app

ENV NVM_DIR /usr/src/app/.nvm
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

