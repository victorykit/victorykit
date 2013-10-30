#!/bin/bash

. "/home/admin/vk/current/bin/vk_env.sh"

cd "/home/admin/vk/current"

echo $@
exec $@
