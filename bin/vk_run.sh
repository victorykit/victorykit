#!/bin/bash

application="vk"

topdir="/home/admin"
appdir="${topdir}/${application}"
current_path="${appdir}/current"
shared_path="${appdir}/shared"

if [ -z "$RBENV_SHELL" ] ; then
  PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH:/usr/local/sbin:/usr/local/bin:$HOME/bin"; export PATH
  eval "$(rbenv init -)"
fi

. "/home/admin/vk/current/bin/vk_env.sh"

cd "${appdir}/current"

exec bundle exec $@
