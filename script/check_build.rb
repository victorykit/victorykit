#!/usr/bin/env ruby

require File.expand_path('../../config/application', __FILE__)
require 'daemons'
require 'selenium/webdriver'
require 'rails_on_fire'
require 'build_checker'

def start
  demonize
  log("build checker is now started")
end

def stop
  demonize
  log "build checker is now stopped"
end

def demonize
  Daemons.run_proc('build_checker', :dir_mode => :normal, :dir => '/var/tmp/', :monitor => false) do

    rof_user = ENV['ROF_USER']
    rof_password = ENV['ROF_PASSWORD']
    
    raise "You need to set ROF_USER and ROF_PASSWORD env vars" if !rof_user || !rof_password

    begin
      d = Selenium::WebDriver.for :chrome
      rof = RailsOnFire.new d, rof_user, rof_password
      BuildChecker.new(rof, VictoryKitChat).run
    ensure
      d.quit
    end
  end
end

case ARGV[0]
  when 'start'
    start
  when 'stop'
    stop
  else
    puts "usage: check_build start|stop"
end



