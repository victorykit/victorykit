#  set :bundle_gemfile,  "Gemfile"
#  set :bundle_dir,      File.join(fetch(:shared_path), 'bundle')
#  set :bundle_flags,    "--deployment --quiet"
#  set :bundle_without,  [:development, :test]
#  set :bundle_cmd,      "bundle" # e.g. "/opt/ruby/bin/bundle"
#  set :bundle_roles,    {:except => {:no_release => true}} # e.g. [:app, :batch]
set :default_environment, {
 'LANG'   => "en_US.UTF-8",
 'LC_ALL' => "en_US.UTF-8"
}
set :default_shell, "bash -l"

require "bundler/capistrano"
load 'deploy/assets'

set :application, "vk"

set :use_sudo, false
default_run_options[:pty] = true

# Repo info
set :repository, "git@github.com:victorykit/victorykit.git"
set :scm, "git"
ssh_options[:forward_agent] = true
set :branch, "root_strikers"
set :deploy_via, :remote_cache

# Deploy target info
set :deploy_to, "/home/admin/vk"
role :web, "vk.rootstrikers.org"
role :app, "vk.rootstrikers.org"
role :db,  "vk.rootstrikers.org", :primary => true

namespace :symlinks do
  desc "[internal] Updates the symlinks to config files (for the just deployed release)."
  task :set_links, :except => { :no_release => true } do
    [
      'database.yml', 'memcached.yml'
    ].each do |file|
      run "if [ -e #{shared_path}/config/#{file} ]; then ln -nfs #{shared_path}/config/#{file} #{release_path}/config/#{file}; fi"
    end
    [
      'log', 'pids'
    ].each do |file|
      run "if [ -e #{shared_path}/#{file} ]; then ln -nfs #{shared_path}/#{file} #{release_path}/#{file}; fi"
    end
    #run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
  end
  after "deploy:finalize_update", "symlinks:set_links"
end


set :rails_env, "production"
set :unicorn_binary, "#{shared_path}/bundle/ruby/2.0.0/bin/unicorn"
set :unicorn_config, "#{current_path}/config/unicorn-prod.rb"
set :unicorn_pid,    "#{current_path}/pids/vk_master.pid"
 
namespace :deploy do
  desc "Start unicorn when its not running"
  task :start, :roles => :app, :except => { :no_release => true } do 
    run "cd #{current_path} && #{current_path}/bin/fc_env_run.sh bundle exec #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
  end
  desc "Stops unicorn immediately w/o waiting for active requests to complete"
  task :hard_stop, :roles => :app, :except => { :no_release => true } do 
    run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end
  desc "Gracefully stops unicorn"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
  end
  desc "Gracefully restarts unicorn"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end
  desc "Performs a 'hard_stop' followed by a 'start'"
  task :hard_restart, :roles => :app, :except => { :no_release => true } do
    hard_stop
    start
  end
  task :echo_env do
    run "env | sort"
  end
  task :echo_env do
    run "#{current_path}/bin/vk_env_run.sh env | sort"
  end
end

