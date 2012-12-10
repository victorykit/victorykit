require 'sent_email_hasher'

class EmailProcessor < ActionMailer::Base

  def handle_exceptional_email(email, from_address, to_address, cause)
    begin
      if (to_address)
        address, domain = to_address.split("@")
        hash = address.gsub(/^[\w\.\-]+\+?/, "") #should remove everything up to and including the first '+'.  Hashes can contain pluses! abc+23+asd@foo.com
        if sent_email = SentEmail.find_by_hash(hash)
          bounced_email = BouncedEmail.new(raw_content: email.to_s, sent_email: sent_email)
          bounced_email.save!
        else
          Rails.logger.warn "Failed to find a ScheduledEmail for hash #{hash}. Possibly lowercased?"
        end
        unsubscribe = Unsubscribe.new(email: from_address, cause: cause)
        unsubscribe.member = Member.find_by_email(from_address)
        if unsubscribe.member
          unsubscribe.save!
        end
      end
    rescue => error
      Airbrake.notify(error)
      puts "Error in processing exceptional mail #{error}"
    end
  end

end
