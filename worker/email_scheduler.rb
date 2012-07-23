require 'scheduled_email'
require 'petition_emailer'

WEEK = 60*60*24*7

class EmailScheduler
  def self.schedule_email
    max_emails_per_week = 40000
    MailerProcessTracker.in_transaction do
      while 1
        PetitionEmailer.send
        sleep(WEEK/max_emails_per_week)
      end
    end
  end
end

EmailScheduler.schedule_email
