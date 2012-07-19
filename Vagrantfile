# -*- mode: ruby -*-
# vi: set ft=ruby :
HERE = File.dirname(__FILE__)
INFRA_DIR  = "#{HERE}/infra"

Vagrant::Config.run do |config|
  config.vm.customize [
      "modifyvm", :id,
      "--memory", "1024",
      "--cpus", "2"
    ]

  # This loads in a base box that is like a heroku cedar stack node
  config.vm.box     = "heroku"
  config.vm.box_url = "https://dl.dropbox.com/u/219714/vagrant-boxes/heroku.box"

  config.vm.forward_port 5432, 5432 # postgres
  config.vm.forward_port 6379, 6379 # redis
  config.vm.forward_port 3000, 3001 # rails s

  # using the brightbox bleeding edge 1.9.3
  # http://blog.brightbox.co.uk/posts/next-generation-ruby-packages-for-ubuntu
  config.vm.provision :shell, :path => "#{INFRA_DIR}/script/server_bootrap.sh"

  config.vm.provision :chef_solo do |chef|
    config.vm.share_folder "workspace", "/home/vagrant/workspace", "#{HERE}"

    chef.cookbooks_path = ["#{INFRA_DIR}/site-cookbooks", "#{INFRA_DIR}/cookbooks"]
    chef.add_recipe("apt")
    chef.add_recipe("heroku_addons::postgresql")
    chef.add_recipe("heroku_addons::redis")
    chef.add_recipe("workstation::mysql")
    chef.add_recipe("workstation::bash")
    chef.json = {
      :postgresql => {
        :listen_addresses => "*",
        :pg_hba => [ "host    all             all             0.0.0.1/0            trust",
                     "host    all             all             ::1/0                trust"],
      }
    }
  end
end
