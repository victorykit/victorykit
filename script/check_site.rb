require 'daemons'

def broadcast_on_skype message
  require 'skypemac'
  vkchat = SkypeMac::Chat.recent_chats.find {|c|c.topic == "VictoryKit Chat"}
  if(vkchat)
    vkchat.send_message message
  else
    raise "Could not find Victory Kit chat on Skype"
  end
end

def start
  demonize
  puts "site checker is now started"
end

def stop
  demonize
  puts "site checker is now stopped"
end

def demonize
  Daemons.run_proc('check_site', :dir_mode => :normal, :dir => '/var/tmp/', :monitor => false) do
    while true
      status = `curl --head -s act.watchdog.net | awk 'NR==1{print $2}'`
      status.strip!
      if status == '500'
        broadcast_on_skype "hey idiots, the site is broken"
      end
      sleep 60
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
