
service 'postgresql' do
  action :stop
  not_if '/usr/bin/pg_ctl --version | grep 9.1'
end

directory '/var/pgsql' do
  action :delete
  recursive true
  not_if '/usr/bin/pg_ctl --version | grep 9.1'
end

include_recipe 'postgresql::apt_postgresql_ppa'
include_recipe 'postgresql::server'

service 'postgresql' do
  action :start
  provider Chef::Provider::Service::Init
end
