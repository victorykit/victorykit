#!/bin/bash

LANG="en_US.UTF-8"; export LANG
LC_ALL="en_US.UTF-8"; export LC_ALL

RAILS_ENV=production; export RAILS_ENV
RACK_ENV=production; export RACK_ENV

cd "/home/admin/vk/current"

echo $@
exec $@
