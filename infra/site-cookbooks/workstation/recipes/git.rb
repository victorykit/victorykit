
package 'git-core'

cookbook_file '/home/vagrant/.gitconfig' do
  owner 'vagrant'
  group 'vagrant'
  mode 0644
  source 'gitconfig'
end
