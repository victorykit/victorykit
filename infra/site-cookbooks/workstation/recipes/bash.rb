template '/home/vagrant/.bashrc' do
  owner 'vagrant'
  group 'vagrant'
  mode 0644
  source 'bashrc.erb'
end

template '/home/vagrant/.bash_profile' do
  owner 'vagrant'
  group 'vagrant'
  mode 0644
  source 'bash_profile.erb'
end

