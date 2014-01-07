#!/usr/bin/env ruby

require 'rubygems'
require 'daemons'
require 'bundler/setup'

cmd = ARGV[0] || 'start'

options = {
  :app_name   => "email_scheduler",
  :ARGV       => [cmd, '--', 'rails', 'runner', 'worker/test.rb'],
  :dir_mode   => :script,
  :dir        => '../pids',
  :multiple   => false,
  :ontop      => true,
  :mode       => :exec,
  :log        => '../log',
  :log_output => true,
  :backtrace  => false,
  :monitor    => false
}

Daemons.run('bin/vk_run.sh', options)
