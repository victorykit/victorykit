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

To setup vagrant you'll first need to remove postgresql and redis from your
local OSX machine first.

    $ ls ~/Library/LaunchAgents

You should see 2 of the files looking like they're related to postgresql and
redis. For each file unload them with the following command:

    $ launchctl unload ~/Library/LaunchAgents/<your plist file name>

This doesn't uninstall the services, but stops them from running.

    $ ./script/bootstrap_vagrant

If you get a message like the following:

    The VM failed to remain in the "running" state while attempting to boot.
    This is normally caused by a misconfiguration or host system incompatibilities.
    Please open the VirtualBox GUI and attempt to boot the virtual machine
    manually to get a more informative error message.

This means that /Applications doesn't have the write permissions. For some
reason VirtualBox doesn't like it when that directory is world writable. The
following should resolve that:

    $ sudo chmod o-w /Applications

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
