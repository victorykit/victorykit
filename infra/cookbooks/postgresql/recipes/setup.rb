#
# Cookbook Name:: postgresql
# Recipe:: setup
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

setup_items = []

node['postgresql']['setup_items'].each do |itemname|
  search(:postgresql, "id:#{itemname}") do |i|
    setup_items << i
  end
end

setup_items.each do |setup|
  
  # The postgres user's password is automatically created
  # in the server cookbook. It's available in
  #   node['postgresql']['password']['postgres']
  pg_connection_info = {
    :host => "127.0.0.1",
    :port => "5432",
    :username => "postgres",
    :password => node['postgresql']['password']['postgres']
  }
  
  # Create database Users
  setup["users"].each do |user|
    postgresql_database_user user['username'] do
      Chef::Log.info("Creating Postgresql user: #{user['username']}")
      connection pg_connection_info
      password user['password']
      action :create
      #database_name instance_name
      #action [:create, :grant]
    end
  end
  
  # Create the app's DB
  setup["databases"].each do |db|
    postgresql_database db["name"] do
      Chef::Log.info("Creating Postgresql database: #{db['name']}")
      connection pg_connection_info
      owner     db["owner"]
      encoding  db["encoding"]
      template  db["template"]
      action :create
    end
  end
end

# Reset the pg_hba.conf file, so connections via 
# unix sockets are via md5 instead of ident
#template "#{node['postgresql']['dir']}/pg_hba.conf" do
  #source "pg_hba.conf.erb"
#end
