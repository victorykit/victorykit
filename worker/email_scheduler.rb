require 'scheduled_email'
require 'petition_emailer'

WEEK = 60*60*24*7

class EmailScheduler
  
  def self.schedule_email
    MailerProcessTracker.in_transaction do
      while 1
        max_emails_per_week = Member.count.to_f
        last_email = Time.now
        send_email
        interval = WEEK/max_emails_per_week - (Time.now-last_email)
        sleep(interval) unless interval < 0
      end
    end
  end

  def self.send_email
    PetitionEmailer.send
    MailerProcessTracker.update
  end
end


EmailScheduler.schedule_email