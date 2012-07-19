#!/bin/sh

set -e

if [ -e /usr/local/bin/chef-solo ]; then
  echo This kitchen is ready!
  exit 0
fi

sudo apt-get update

sudo apt-get -y install python-software-properties
sudo apt-add-repository ppa:brightbox/ruby-ng-experimental

sudo apt-get update

sudo apt-get -y install ruby rubygems ruby-switch ruby1.9.3
sudo ruby-switch --set ruby1.9.1

echo Finally... installing chef
sudo gem install chef --no-ri --no-rdoc
sudo gem install bundler --no-ri --no-rdoc

