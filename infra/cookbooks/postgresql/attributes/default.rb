#
# Cookbook Name:: postgresql
# Attributes:: postgresql
#
# Copyright 2008-2009, Opscode, Inc.
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

case platform
when "debian"

  if platform_version.to_f == 5.0
    default[:postgresql][:version] = "8.3"
  elsif platform_version =~ /squeeze/
    default[:postgresql][:version] = "8.4"
  end

  set[:postgresql][:dir] = "/etc/postgresql/#{node[:postgresql][:version]}/main"

when "ubuntu"

  case
  when platform_version.to_f <= 9.04
    default[:postgresql][:version] = "8.3"
  when platform_version.to_f <= 11.04
    default[:postgresql][:version] = "8.4"
  else
    default[:postgresql][:version] = "9.1"
  end

  set[:postgresql][:dir] = "/etc/postgresql/#{node[:postgresql][:version]}/main"

when "fedora"

  if platform_version.to_f <= 12
    default[:postgresql][:version] = "8.3"
  else
    default[:postgresql][:version] = "8.4"
  end

  set[:postgresql][:dir] = "/var/lib/pgsql/data"

when "redhat","centos","scientific","amazon"

  default[:postgresql][:version] = "8.4"
  set[:postgresql][:dir] = "/var/lib/pgsql/data"

when "suse"

  if platform_version.to_f <= 11.1
    default[:postgresql][:version] = "8.3"
  else
    default[:postgresql][:version] = "8.4"
  end

  set[:postgresql][:dir] = "/var/lib/pgsql/data"

else
  default[:postgresql][:version] = "8.4"
  set[:postgresql][:dir]         = "/etc/postgresql/#{node[:postgresql][:version]}/main"
end

# Host Based Access
default[:postgresql][:hba] = [
  { :method => 'md5', :address => '127.0.0.1/32' },
  { :method => 'md5', :address => '::1/128' }
]

# Replication/Hot Standby (set to postgresql defaults)
# PostgreSQL 9.1
# ----------------------------------------------------
default[:postgresql][:listen_addresses] = "localhost"

# Master Server
default[:postgresql][:master] = false # Is this a master?
# None of the below settings get written unless the above is set to "true"
default[:postgresql][:wal_level] = "minimal"
default[:postgresql][:max_wal_senders] = 0
default[:postgresql][:wal_sender_delay] = "1s"
default[:postgresql][:wal_keep_segments] = 0
default[:postgresql][:vacuum_defer_cleanup_age] = 0
default[:postgresql][:replication_timeout] = "60s"
# If you want to do synchronous streaming replication, 
# profide a string containing a comma-separated list of 
# node names for "synchronous_standby_names"
default[:postgresql][:synchronous_standby_names] = nil 
# list of IP addresses for standby nodes
default[:postgresql][:standby_ips] = [] 

# Standby Servers
default[:postgresql][:standby] = false # Is this a standby?
default[:postgresql][:master_ip] = nil # MUST Be specified in the role
# None of the below settings get written unless the above is set to "true"
default[:postgresql][:hot_standby] = "off"
default[:postgresql][:max_standby_archive_delay] = "30s"
default[:postgresql][:max_standby_streaming_delay] = "30s"
default[:postgresql][:wal_receiver_status_interval] = "10s"
default[:postgresql][:hot_standby_feedback] = "off"

# Role/Database Setup
default[:postgreql][:setup_items] = [] # list of data bag names

