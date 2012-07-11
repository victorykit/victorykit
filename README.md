VictoryKit is a free and open source platform to run campaigns for social change.

## Initial Setup

To checkout the code:

    $ git clone git@github.com:scottmuc/victorykit.git

## Vagrant Installation

    $ script/bootstrap
    $ vagrant up
    $ vagrant ssh
    $ cd workspace
    $ rake # not 100% working yet
    $ script/server

## Max OSX Installation

On a Mac, you'll want to install:

    $ brew install redis
    $ brew install mysql
    $ brew install chromedriver

You may already have a version of Postgres installed, in which case [you'll need to remove it](https://gist.github.com/2471603) with:

    $ mkdir /tmp/postg
    $ sudo mv /usr/include/pg* /tmp/postg
    $ brew update
    $ brew install postgresql

To confirm you have the appropriate requirements:

    $ cd victorykit
    $ ./script/bootstrap

## Usage

Make sure the tests pass:

    $ rake

Start the local server:

    $ rails server
