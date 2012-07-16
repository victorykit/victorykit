# -*- mode: ruby -*-
# vi: set ft=ruby :
HERE = File.dirname(__FILE__)
INFRA_DIR  = "#{HERE}/infra"

Vagrant::Config.run do |config|
  # This loads in a base box that is like a heroku cedar stack node
  config.vm.box     = "heroku"
  config.vm.box_url = "https://dl.dropbox.com/u/219714/vagrant-boxes/heroku.box"

  config.vm.forward_port 5432, 5432 # postgres

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["#{INFRA_DIR}/site-cookbooks", "#{INFRA_DIR}/cookbooks"]
    chef.add_recipe("apt")
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
