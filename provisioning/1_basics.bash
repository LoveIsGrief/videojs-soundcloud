#!/bin/bash

INITIAL_NODE_VERSION=6

# Get NVM
install_nvm(){
    if ! grep nvm ~/.profile ; then
        wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
        # Install a basic node version
        npm install ${INITIAL_NODE_VERSION}
    fi
    # Make sure we can execute project local commands
    if ! grep node_modules ~/.bashrc ; then
        echo 'export PATH=./node_modules/.bin:$PATH' >> ~/.bashrc
    fi
}


install_latest_firefox(){
    echo "Install newest firefox the travis way"
    # http://redsymbol.net/articles/unofficial-bash-strict-mode/
    set -euo pipefail
    IFS=$'\n\t'

    # Activate debugging
    set -x

    # Download the latest tar
    export FIREFOX_SOURCE_URL='https://download.mozilla.org/?product=firefox-latest&lang=en-US&os=linux64'
    FF_PATH_ROOT=$HOME/firefox-latest
    FF_PATH=$FF_PATH_ROOT/firefox
    mkdir -p $FF_PATH_ROOT
    FF_DL=/tmp/firefox-latest.tar.bz2
    if ! [[ -e $FF_DL ]] ; then
        wget -O $FF_DL --no-clobber --continue $FIREFOX_SOURCE_URL
    fi

    # Unpack the tar and make sure it'll be found in PATH
    if ! [[ -e $FF_PATH ]] ; then
        tar xvf $FF_DL -C $FF_PATH_ROOT
        echo "export PATH=$FF_PATH:"'$PATH' >> ~/.bashrc
    fi
}

install_xvfb(){
    if ! which Xvfb ; then
        echo "installing xvfb"
        sudo apt-get install Xvfb -y

        echo "Make the xvfb service as it exists on a travis machine"
        sudo cp /vagrant/provisioning/files/xvfb.service.bash /etc/init.d/xvfb
        sudo chmod +x /etc/init.d/xvfb
    else
        echo "xvfb already installed"
    fi
}

install_nvm
install_latest_firefox
install_xvfb

# The actual "before_install" part of the .travis.yml
# Do NOT execute this twice!
# Some of these commands shouldn't be run twice!

#sudo apt-get update -qq
## Install the requirements for adding repos
## apt-add-repository is in there
#sudo apt-get install -y python-software-properties
## Add repos
## sudo apt-add-repository "deb http://deb.opera.com/opera/ stable non-free"
#if ! grep "dl.google.com" /etc/apt/sources.list /etc/apt/sources.list.d/* ; then
#    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chome.list
#fi
## Remove "deb-src" repos added from apt-add-repository, because it doesn't exist online
#sudo sed -i s/deb-src.*opera.*//g /etc/apt/sources.list
#sudo sed -i s/deb-src.*google.*//g /etc/apt/sources.list
## Add apt-keys for checking the packages
#wget -O - http://deb.opera.com/archive.key | sudo apt-key add -
#wget -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
#sudo apt-get update -qq
## Install the browsers
#sudo apt-get install -y chromium-browser google-chrome-stable xvfb
## Install what's needed to play mp4s with firefox
#sudo apt-get install libavcodec-extra
## Install grunt and bower globally
#npm install -g grunt-cli bower
# Setup xvfb for browsers
#export DISPLAY=:99.0
#sh -e /etc/init.d/xvfb start
