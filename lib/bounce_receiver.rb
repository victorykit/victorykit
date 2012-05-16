require 'hasher'

class BounceReceiver < ActionMailer::Base
  
  def receive_bounced_email(email, to_address)
    begin
      handle_delivery_failure(email, to_address)
    rescue => error
      puts "Error in receiving bounced mail #{error}"
    end  
  end
  
  def handle_delivery_failure(email, to_address)
    if (to_address)
      address, domain = to_address.to_s.split("@")

      if h = Hasher.validate(address.gsub("bounce+", ""))
        sent_email = SentEmail.find_by_id(h)
        if sent_email
          bounced_email = BouncedEmail.new(raw_content: email.to_s, sent_email: sent_email)
          bounced_email.save!

          unsubscribe = Unsubscribe.new(email: sent_email.email, cause: "bounced")
          unsubscribe.member = Member.find_by_email(sent_email.email) 
          if unsubscribe.member
            unsubscribe.save!
          end
        end
      end
    end
  end
end