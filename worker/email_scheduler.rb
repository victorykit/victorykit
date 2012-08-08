require 'scheduled_email'
require 'petition_emailer'

WEEK = 60*60*24*7

class EmailScheduler
  def self.schedule_email
    max_emails_per_week = Member.count.to_f

    MailerProcessTracker.in_transaction do
      while 1
        last_email = Time.now
        PetitionEmailer.send
        interval = WEEK/max_emails_per_week - (Time.now-last_email)
        sleep(interval) unless interval < 0
      end
    end
  end
end

EmailScheduler.schedule_email