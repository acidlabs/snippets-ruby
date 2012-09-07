#!/bin/bash

# MacPorts
wget https://distfiles.macports.org/MacPorts/MacPorts-2.1.2-10.6-SnowLeopard.pkg
hdiutil attach MacPorts-2.1.2-10.6-SnowLeopard.pkg
sudo installer -verbose -pkg /Volumes/MacPorts-2.1.2/MacPorts-2.1.2.pkg -target /
sudo port install coreutils lesspipe

# Homebrew
ruby -e "$(curl -fsSL https://raw.github.com/gist/323731)"
brew install wget git bash-completion node mysql postgresql mongodb

# Npm
curl http://npmjs.org/install.sh | sh
npm install coffee-script -g

# Rvm
bash < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )
rvm pkg install libxml2
rvm pkg install libxslt
rvm pkg install ree_dependencies
rvm install 1.8.7
rvm install 1.9.2
rvm install 1.9.3
rvm use 1.9.3@global --default
rvm install rbx -- --enable-version=1.9,1.8 --default-version=1.9