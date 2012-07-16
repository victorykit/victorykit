
bash 'install redis' do
  cwd '/tmp'
  code <<-EOH
    wget http://redis.googlecode.com/files/redis-2.4.1.tar.gz
    tar xvfz redis-2.4.1.tar.gz
    cd redis-2.4.1/
    mkdir -p /opt/redis
    make PREFIX=/opt/redis install
  EOH
  not_if 'test -f /etc/init.d/redis'
end

template '/etc/init.d/redis' do
  source 'initd.erb'
  mode '0700'
end

user 'redis' do
  system true
  shell '/bin/false'
end

template '/opt/redis/redis.conf' do
  source 'redis.conf.erb'
  mode '0644'
end

service 'redis' do
  action [:enable, :start]
end
