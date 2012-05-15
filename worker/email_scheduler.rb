require 'scheduled_email'
require 'petition_emailer'

class EmailScheduler

  def self.schedule_email
    max_emails_per_day = 1000
    while 1
      MailerProcessTracker.in_transaction do
        PetitionEmailer.send
      end
      sleep(60*60*24/max_emails_per_day)
    end
  end
end

EmailScheduler.schedule_email