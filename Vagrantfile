# -*- mode: ruby -*-
# vi: set ft=ruby :
HERE = File.dirname(__FILE__)
INFRA_DIR = "#{HERE}/infra"

Vagrant::Config.run do |config|
  config.vm.box = "heroku"

  config.vm.define :dev do |config|
    config.vm.share_folder "rails_app", "/home/vagrant/workspace", "#{HERE}"

    config.vm.forward_port 9292, 9292 # rackup
    config.vm.forward_port 3000, 3000 # rails server

    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ["#{INFRA_DIR}/site-cookbooks", "#{INFRA_DIR}/cookbooks"]
      chef.add_recipe "workstation::git"
      chef.add_recipe "workstation::bash"
      chef.add_recipe "workstation::vim"
      chef.add_recipe "workstation::rubygems"
      chef.add_recipe "workstation::mysql"
      chef.add_recipe "heroku_addons::postgresql"
      chef.add_recipe "heroku_addons::redis"
    end
  end
end
