#!/usr/bin/env ruby

# Taken from https://github.com/marcocampana/git-notifier

require 'rubygems'
require 'daemons'
require 'digest/sha1'

def usage
  usage = <<END

  Usage:
  ------

  git-notifier start|stop|add|clear|status


  Examples:
  ---------

  Start the notifier:
    git-notifier start

  Stop the notifier:
    git-notifier stop

  Add a repository to the watch list:
    git-notifier add <repo_uri> <branch>
    Example: git-notifier add git@github.com:marcocampana/git-notifier.git master

  Remove all watched repositories from the watch list
    git-notifier clear

  Show all the watched repositories
    git-notifier status
END
end

def add_repo
  (puts usage and return) if ARGV.size < 2
  repo_uri        = ARGV[1]
  branch          = ARGV[2] || 'master'
  repo_name       = repo_uri.split("/").last
  repo_local_path = "/var/tmp/git-notifier_#{Digest::SHA1.hexdigest(repo_uri)}_#{repo_name}_#{branch}"
  # TODO Truncate the SHA1 in the filename

  if !File.exists?( repo_local_path )
    log "git-notifier: adding #{repo_uri} to watch list... (this might take a while)"
    output = `mkdir #{repo_local_path}; cd #{repo_local_path}; git clone #{repo_uri} . 2>/dev/null`
    # TODO Add error handling in case the repo does not exist
  end
  log "git-notifier: repo '#{repo_uri}' added to watch list"
end

def start
  demonize
  log("git-notifier is now started")
end

def stop
  demonize
  log "git-notifier is now stopped"
end

def status
  watched_repos = []
  available_repos.each do |repo_dirname|
    prefix, repo_sha1, repo_name, repo_branch = repo_dirname.split('_')
    watched_repos << [repo_name, repo_branch]
  end
  if watched_repos.any?
    # TODO Show if the notifier is running or not
    puts "git-notifier: the following repositories are in the watch list"
    watched_repos.each do |repo|
      puts " - #{repo[0]} (#{repo[1]})"
    end
  else
    puts "git-notifier: no repositories are being watched at the moment\nUse: 'git-notifier add <repo_uri>' to add repos to watch"
  end
end

def available_repos
  repos = []
  Dir.new('/var/tmp').each do |repo_dir|
    repos << repo_dir if repo_dir =~ /^git-notifier_/
  end
  repos
end

def clear_all
  repos = available_repos
  repos.each do |repo|
    log "/var/tmp/#{repo} deleted"
    `cd /var/tmp; rm -Rf #{repo}` if repo =~ /^git-notifier/
  end
  puts "git-notifier: no repositories are being watched at the moment\nUse: 'git-notifier add <repo_uri>' to add repos to watch" if repos.empty?
end

def demonize
  Daemons.run_proc('git-notifier', :dir_mode => :normal, :dir => '/var/tmp/', :monitor => false) do
    loop do
      # TODO store available_repoes in a variable if adding while running doesn't work
      available_repos.each do |repo_dirname|
        prefix, repo_sha1, repo_name, repo_branch = repo_dirname.split('_')

        git_pull_output = `cd /var/tmp/#{repo_dirname}; git checkout -b #{repo_branch} >/dev/null 2>&1; git pull origin #{repo_branch} 2>/dev/null`

        if git_pull_output =~ /Updating (.+)\.\.(.+)/
          from_commit = $1
          to_commit   = $2

          log("new commit detected:")
          log(git_pull_output)

          #TODO: log all commits since last checkout, not just most recent
          git_log_output = `cd /var/tmp/#{repo_dirname}; git log -1 --pretty=format:"%h - %an, %ar : %s"`
          commit = `cd /var/tmp/#{repo_dirname}; git log -1 --pretty=format:"%h"`
          broadcast_on_skype "New commit: #{git_log_output}"
          broadcast_on_skype "https://github.com/victorykit/victorykit/commit/#{commit}"
        end
        # TODO increase sleep time
        sleep(60)
      end
    end
  end
end

def broadcast_on_skype message
  require 'skypemac'
  vkchat = SkypeMac::Chat.recent_chats.find {|c|c.topic == "VictoryKit Chat"}
  if(vkchat)
    vkchat.send_message message
    log("Sent to Skype: #{message}")
  else
    log("Could not find Victory Kit chat on Skype")
  end
end

def log(message)
  puts message
  File.open("/var/tmp/git-notifier.log", 'a') do |file|
    file.puts Time.now.to_s + ": " + message
  end
end

case ARGV[0]
  when 'start'
    start
  when 'add'
    add_repo
  when 'stop'
    stop
  when 'clear'
    clear_all
  when 'status'
    status
  else
    puts usage
end