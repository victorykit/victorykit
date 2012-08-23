#!/usr/bin/env ruby

require File.expand_path('../../config/application', __FILE__)

require 'selenium/webdriver'
require 'rails_on_fire'
require 'build_checker'

$rof_user = ENV['ROF_USER']
$rof_password = ENV['ROF_PASSWORD']

raise "You need to set ROF_USER and ROF_PASSWORD env vars" if !$rof_user || !$rof_password

begin
  d = Selenium::WebDriver.for :chrome
  rof = RailsOnFire.new d
  BuildChecker.new(rof).run
ensure
  d.quit
end