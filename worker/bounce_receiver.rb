require 'hasher'

class BounceReceiver < ActionMailer::Base
  
  def receive(email)
    begin 
      handle_delivery_failure(email['return-path'])
    rescue => error
      puts "Error in receiving bounced mail #{error}"
    end  
  end
  
  def handle_delivery_failure(email_return_path)
    if (email_return_path)
      address, domain = email_return_path.to_s.split("@")

      if h = Hasher.validate(address.gsub("bounce-", ""))
        sent_email = SentEmail.find_by_id(h)
        if(sent_email)
          unsubscribe = Unsubscribe.new(email: sent_email.email, cause: "bounced")
          unsubscribe.member = Member.find_by_email(sent_email.email) 
          unsubscribe.save!
        end
      end
    end
  end
end

=begin
#Test data
email = ActionMailer::Base.mail
email['from'] = 'info@watchdog.net'
email['return-path'] = 'bounce-421.2EjDTn@watchdog.net'
email[:to]    = 'you@test.net'
email.subject = 'This is a test email'
email.body    = 'This is a body'
BounceReceiver.receive(email.to_s)
=end



