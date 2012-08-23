def broadcast_on_skype message
  require 'skypemac'
  vkchat = SkypeMac::Chat.recent_chats.find {|c|c.topic == "VictoryKit Chat"}
  if(vkchat)
    vkchat.send_message message
  else
    raise "Could not find Victory Kit chat on Skype"
  end
end

while true
  status = `curl --head -s act.watchdog.net | awk 'NR==1{print $2}'`
  status.strip!
  if status != '200'
    broadcast_on_skype "hey idiots, the site is broken"
  end
  print "Received #{status} from act.watchdog.net\r"
  $stdout.flush
  sleep 60
end
