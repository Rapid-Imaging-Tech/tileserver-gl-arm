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

# install version 6 of node, as required by tileserver-gl
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install v6.15.1

# initialize the submodules
cd $HOME
git submodule init
git submodule update

# build mapbox-gl-native
cd $HOME/mapbox-gl-native
git checkout arm-64-build
cp /usr/bin/ninja platform/linux/

make node

# installs tileserver-gl WITHOUT the mapbox-gl-native
# dependency - we need to use the one we built.
cd $HOME/tileserver-gl
git checkout arm-64-build
npm install --build-from-source

# copy the stuff we need from mapbox-gl-native
mkdir -p node_modules/@mapbox/mapbox-gl-native
mv $HOME/mapbox-gl-native/lib/ node_modules/@mapbox/mapbox-gl-native/

mkdir -p node_modules/@mapbox/mapbox-gl-native/platform/node
cp $HOME/mapbox-gl-native/platform/node/index.js node_modules/@mapbox/mapbox-gl-native/platform/node/

cp $HOME/mapbox-gl-native/package.json node_modules/@mapbox/mapbox-gl-native/

rm -rf .git

# copy tileserver-gl to it's final location and clean up
mkdir -p /usr/src
cd
mv tileserver-gl/ /usr/src/app

rm -rf $HOME/mapbox-gl-native


