require 'github_api'
require 'daemons'
require 'time-lord'

#TODO: parameterize
USER = "victorykit"
REPO = "victorykit"

def start
  if !File.exists?(file_path)
    log `mkdir -p #{file_path}`
  end

  head = Github.new.git_data.references.find('victorykit', 'victorykit', 'heads/master')['object']['sha']
  store head
  demonize
  log("commitron is now started")
end

def stop
  demonize
  log "commitron is now stopped"
end

def demonize
  Daemons.run_proc('commitron', :dir_mode => :normal, :dir => '/var/tmp/', :monitor => false) do
    loop do
      find_new_commits
      sleep(60)
    end
  end
end

def find_new_commits
  begin
    all_commits = Github.new.repos.commits.all(USER, REPO)
    index_of_last_known_commit = all_commits.index {|c| c['sha'] == last_known_commit}

    #TODO: handle case where last_known_commit is not in the first page of results
    if(index_of_last_known_commit && index_of_last_known_commit > 0)
      new_commits = all_commits[0..index_of_last_known_commit]

      new_commits.each do |c|
        committer = c['commit']['committer']['name']
        commit_time = Time.parse(c['commit']['committer']['date']).ago_in_words
        message = c['commit']['message']
        small_sha = c['sha'][0..6]
        url = "https://github.com/#{USER}/#{REPO}/commit/#{c['sha']}"
        broadcast_on_skype "New commit: #{small_sha} - #{committer}, #{commit_time} : #{message} \n #{url}"
      end
    end

    store all_commits.first['sha']
  rescue => ex
    log ex
    log ex.backtrace.join
  end
end

def last_known_commit
  IO.read(state_file).strip
end

def store(sha)
  File.open(state_file, 'w') do |file|
    file.puts sha
  end

  log "updated last known commit to #{sha}"
end

def file_path
  "/var/tmp/commitron/#{USER}/#{REPO}/"
end

def state_file
  [file_path, "last_commit"].join
end

def log(message)
  puts message
  File.open([file_path, "commitron.log"].join, 'a') do |file|
    file.puts "#{Time.now.to_s}: #{message}"
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

case ARGV[0]
  when 'start'
    start
  when 'stop'
    stop
  when 'once'
    find_new_commits
  else
    puts "usage: commitron start|stop"
end