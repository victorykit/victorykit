require 'hasher'

class EmailProcessor < ActionMailer::Base

  def handle_exceptional_email(email, to_address, cause)
    begin
      if (to_address)
        address, domain = to_address.to_s.split("@")

        if h = Hasher.validate(address.gsub(/^.+\+/, ""))
          sent_email = SentEmail.find_by_id(h)
          if sent_email
            bounced_email = BouncedEmail.new(raw_content: email.to_s, sent_email: sent_email)
            bounced_email.save!

            unsubscribe = Unsubscribe.new(email: sent_email.email, cause: cause)
            unsubscribe.member = Member.find_by_email(sent_email.email) 
            if unsubscribe.member
              unsubscribe.save!
            end
          end
        end
      end
    rescue => error
      puts "Error in processing exceptional mail #{error}"
    end  
  end

end
