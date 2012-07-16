# -*- mode: ruby -*-
# vi: set ft=ruby :
HERE = File.dirname(__FILE__)
INFRA_DIR = "#{HERE}/infra"

Vagrant::Config.run do |config|
  config.vm.box     = "heroku"
  config.vm.box_url = "https://dl.dropbox.com/u/219714/vagrant-boxes/heroku.box"

  config.vm.define :dev do |config|
    config.vm.share_folder "rails_app", "/home/vagrant/workspace", "#{HERE}"

    config.vm.forward_port 9292, 9292 # rackup
    config.vm.forward_port 3000, 3000 # rails server
    config.vm.forward_port 5432, 5432 # postgres

    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ["#{INFRA_DIR}/site-cookbooks", "#{INFRA_DIR}/cookbooks"]
      chef.add_recipe "apt"
      chef.add_recipe "workstation::git"
      chef.add_recipe "workstation::bash"
      chef.add_recipe "workstation::vim"
      chef.add_recipe "workstation::rubygems"
      chef.add_recipe "workstation::mysql"
      chef.add_recipe "heroku_addons::redis"
      chef.add_recipe("heroku_addons::postgresql")
      chef.json = {
        :postgresql => {
          :version  => "9.1",
          :listen_addresses => "*",
          :hba => [
            { :method => "trust", :address => "0.0.0.0/0" },
            { :method => "trust", :address => "::1/0" },
          ],
          :password => { :postgres => "password" }
        }
      }
    end
  end
end
