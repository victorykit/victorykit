#
# Cookbook Name:: postgresql
# Recipe::apt_postgresql_ppa
#
# Copyright 2012, Coroutine LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Add the PostgreSQL 9.1 sources for Ubuntu
# using the PPA available at:
# https://launchpad.net/~pitti/+archive/postgresql

# NOTE: This requires the "apt" recipe
case node["platform"]
when "ubuntu"
  apt_repository "postgresql" do
    uri "http://ppa.launchpad.net/pitti/postgresql/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "8683D8A2"
    action :add
    notifies :run, resources(:execute => "apt-get update"), :immediately
  end
end
