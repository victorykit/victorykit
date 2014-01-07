#!/usr/bin/env ruby

#
# This is a rather hackish solution inorder to
# daemonize the email_scheduler, but it works
# with no changes to the emailer related code. 
# Caveat emptor...
#

require 'rubygems'
require 'bundler/setup'
require 'daemons'


cmd = ARGV[0] || 'start'

options = {
  :app_name   => "email_scheduler",
  :ARGV       => [cmd, '--', 'rails', 'runner', 'worker/email_scheduler.rb'],
  :dir_mode   => :script,
  :dir        => '../pids/',
  :multiple   => false,
  :ontop      => false,
  :mode       => :exec,
  :log_output => true,
  :backtrace  => false,
  :monitor    => true

# The log output is lost if this option is specified.
# Not specifying the log_dir means the log files
# are written to the pids directory. Sigh...
#
#  :log_dir    => '../log/',
#

}

Daemons.run('bin/vk_run.sh', options)
