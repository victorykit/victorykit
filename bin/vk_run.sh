#!/bin/bash

application="vk"

topdir="/home/admin"
appdir="${topdir}/${application}"
current_path="${appdir}/current"
shared_path="${appdir}/shared"

. "/home/admin/vk/current/bin/vk_env.sh"

cd "${appdir}/current"

echo $@
exec $@
