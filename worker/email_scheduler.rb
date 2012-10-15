require 'scheduled_email'
require 'petition_emailer'

WEEK = 60*60*24*7
BATCH_SIZE = 100

class EmailScheduler
  def self.schedule_email
    max_emails_per_week = Member.count.to_f
    MailerProcessTracker.in_transaction do
      while 1
        last_email = Time.now
        send_email(BATCH_SIZE)
        interval = WEEK/(max_emails_per_week/BATCH_SIZE) - (Time.now-last_email)
        puts "Sleeping " + interval.to_s
        sleep(interval) unless interval < 0
      end
    end
  end

  def self.send_email(n)
    PetitionEmailer.send(n)
    MailerProcessTracker.update
  end
end


EmailScheduler.schedule_email