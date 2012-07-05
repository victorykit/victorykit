VictoryKit is a free and open source platform to run campaigns for social change.

## Installation

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

    $ ./script/bootstrap

## Usage

To make sure the tests pass run `rake` and to start the local server run `rails server`. You can run the smoke tests with `rake spec:smoke`.
