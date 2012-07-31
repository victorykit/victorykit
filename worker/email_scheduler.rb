require 'scheduled_email'
require 'petition_emailer'

WEEK = 60*60*24*7

class EmailScheduler
  def self.schedule_email
    max_emails_per_week = Member.count.to_f
    last_email = Time.new
    MailerProcessTracker.in_transaction do
      while 1
        PetitionEmailer.send
        sleep(WEEK/max_emails_per_week - (Time.new-last_email))
        last_email = Time.new
      end
    end
  end
end

EmailScheduler.schedule_email
