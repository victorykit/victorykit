require 'skypemac'

class VictoryKitChat
  def self.say message
    vkchat = SkypeMac::Chat.recent_chats.find {|c|c.topic == "VictoryKit Chat"}
    if(vkchat)
      vkchat.send_message message
    else
      raise "Could not find Victory Kit chat on Skype"
    end
  end
end