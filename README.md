VictoryKit is a free and open source platform to run campaigns for social change.

![build status](https://semaphoreapp.com/api/v1/projects/bfa043263901870e821c1a460cfb2438a2bdf4c6/4199/badge.png)


## Installation

On a Mac, you'll want to install:

    $ brew install redis postgresql

You may already have a version of Postgres installed, in which case [you'll need to remove it](https://gist.github.com/2471603) with:

    $ brew unlink postgresql
    $ brew install postgresql

To check out the code:

    $ git clone git@github.com:victorykit/victorykit.git

To confirm you have the appropriate requirements:

    $ cd victorykit
    $ ./script/bootstrap

## Usage

Make sure gems are up to date:

    $ bundle

Make sure Postgres is running

Make sure the database exists and is migrated

    $ rake db:create
    $ rake db:migrate
    
Make sure the tests pass:

    $ rake

Make sure Redis is running

Run the app locally

    $ rails server

Alternatively, you can use Foreman:

    $ foreman start -f Procfile.dev -p 3000
