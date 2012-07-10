cookbook_file '/home/vagrant/.bashrc' do
  owner 'vagrant'
  group 'vagrant'
  mode 0644
  source 'bashrc'
end

cookbook_file '/home/vagrant/.bash_profile' do
  owner 'vagrant'
  group 'vagrant'
  mode 0644
  source 'bash_profile'
end

cookbook_file '/home/vagrant/.git-completion.sh' do
  owner 'vagrant'
  group 'vagrant'
  mode 0644
  source 'git-completion.sh'
end
