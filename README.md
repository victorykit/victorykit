VictoryKit is a free and open source platform to run campaigns for social change.

## Installation

On a Mac, you'll want to install:

    $ brew install mysql
    $ brew install chromedriver

To checkout the code:

    $ git clone git@github.com:victorykit/victorykit.git

To confirm you have the appropriate requirements:

    $ cd victorykit
    $ ./script/bootstrap

## Usage

Make sure the tests pass:

    $ rake

Start the local server:

    $ rails server

## Vagrant basics

* `vagrant up` - this starts up the VM from any non-up state (PoweredOff,
  Suspended)
* `vagrant reload` - will reboot the VM. This is generally needed if you are
  changing the Vagrantfile. This will reconfigure the network port-forwarding
  VM/host file system shares.
* `vagrant provision` - executes the provision steps (in our case, it runs chef)
* `vagrant destroy` - completely removes the VM
* `vagrant suspend` - pauses the VM
* `vagrant ssh` - logs into the VM
