package 'vim'

cookbook_file '/home/vagrant/.vimrc' do
  owner 'vagrant'
  group 'vagrant'
  mode 0644
  source 'vimrc'
end
