VictoryKit is a free and open source platform to run campaigns for social change.

## Installation

On a Mac, you'll want to install:

    $ brew install redis
    $ brew install mysql
    $ brew install chromedriver
    $ brew install qt

You may already have a version of Postgres installed, in which case [you'll need to remove it](https://gist.github.com/2471603) with:

    $ mkdir /tmp/postg
    $ sudo mv /usr/include/pg* /tmp/postg
    $ brew update
    $ brew install postgresql

To checkout the code:

    $ git clone git@github.com:victorykit/victorykit.git

To confirm you have the appropriate requirements:

    $ cd victorykit
    $ ./script/bootstrap

## Usage

* Make sure gems are up to date:

    $ bundle

* Make sure Postgres is running

* Make sure the database exists and is migrated

    $ rake db:create
    $ rake db:migrate

* Make sure the tests pass:

    $ rake

To get the smoke tests to pass, you'll need to have the right OAUTH variables, either by running `./script/gen_google_oauth` or getting the right variables from a friend and then setting them in your environment. You'll also need to be running the local server:

* Make sure Redis is running

Run the app locally

    $ rails server

Alternatively, you can use Foreman:

    $ foreman start -f Procfile.dev -p 3000
