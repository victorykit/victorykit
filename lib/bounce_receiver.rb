require 'hasher'

class BounceReceiver < ActionMailer::Base
  
  def receive(email)
    begin
      handle_delivery_failure(email)
    rescue => error
      puts "Error in receiving bounced mail #{error}"
    end  
  end
  
  def handle_delivery_failure(email)
    return_path = email['return-path']
    if (return_path)
      address, domain = return_path.to_s.split("@")

      if h = Hasher.validate(address.gsub("bounce+", ""))
        sent_email = SentEmail.find_by_id(h)
        if(sent_email)
          unsubscribe = Unsubscribe.new(email: sent_email.email, cause: "bounced")
          unsubscribe.member = Member.find_by_email(sent_email.email) 
          unsubscribe.save!
          
          bounced_email = BouncedEmail.new(raw_content: email.to_s, sent_email: sent_email)
          bounced_email.save!
        end
      end
    end
  end
end