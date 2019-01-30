#! /bin/bash

onerror () {
  errcode=$?
  echo 
  echo "Error: $errcode"
  echo "Command: $BASH_COMMAND"
  echo
  exit $errcode
}

trap onerror ERR

DEBIAN_FRONTEND=noninteractive
APP=$HOME/app

apt-get -qq update

apt-get -y install \
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
    libjpeg-turbo8 libjpeg-turbo8-dev \
    libuv1-dev

# install version 6 of node, as required by tileserver-gl
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install v6.15.1

# initialize the submodules
cd $APP
git submodule init
git submodule update

# build mapbox-gl-native
cd $APP/mapbox-gl-native
git checkout arm-64-build
cp /usr/bin/ninja platform/linux/

make node

# installs tileserver-gl WITHOUT the mapbox-gl-native
# dependency - we need to use the one we built.
cd $APP/tileserver-gl
git checkout arm-64-build
npm install --build-from-source --production

# install tileserver-gl-styles
cd $APP/tileserver-gl-styles
node publish.js
npm install . -g

# copy the stuff we need from mapbox-gl-native
mkdir -p node_modules/@mapbox/mapbox-gl-native
mv $APP/mapbox-gl-native/lib/ node_modules/@mapbox/mapbox-gl-native/

mkdir -p node_modules/@mapbox/mapbox-gl-native/platform/node
cp $APP/mapbox-gl-native/platform/node/index.js node_modules/@mapbox/mapbox-gl-native/platform/node/

cp $APP/mapbox-gl-native/package.json node_modules/@mapbox/mapbox-gl-native/

rm -rf .git

# copy tileserver-gl to it's final location and clean up
mkdir -p /usr/src
cd $APP
mv tileserver-gl/ /usr/src/app

rm -rf $APP
rm -rf $HOME/.ccache
rm -rf $HOME/.npm

apt-get -y remove \
    curl \
    unzip \
    build-essential \
    libcairo2-dev \
    libgles2-mesa-dev \
    libgbm-dev \
    libprotobuf-dev \
    libxxf86vm-dev \
    pkg-config python-pip \
    ninja-build \
    libxi-dev libglu1-mesa-dev x11proto-randr-dev \
    x11proto-xext-dev libxrandr-dev \
    x11proto-xf86vidmode-dev libxxf86vm-dev \
    libxcursor-dev libxinerama-dev \
    ccache \
    libjpeg-turbo8-dev

apt -y autoremove
apt-get clean

