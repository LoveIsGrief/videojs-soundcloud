#!/bin/bash

INITIAL_NODE_VERSION=6

# Get NVM
install_nvm(){
    if ! grep nvm ~/.profile ; then
        wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        # Install a basic node version
        nvm install ${INITIAL_NODE_VERSION}
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
        sudo apt-get install Xvfb -qy

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
