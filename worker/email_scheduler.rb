require 'scheduled_email'
require 'petition_emailer'

WEEK = 60*60*24*7
BATCH_SIZE = 100

class EmailScheduler
  def self.schedule_email
    return if ENV['REALLY_SEND_REAL_EMAILS'] != "1"

    sleep_debt = 0
    max_emails_per_week = Member.count.to_f
    MailerProcessTracker.in_transaction do
      while 1
        last_email = Time.now
        send_email(BATCH_SIZE)
        sleep_debt += WEEK/(max_emails_per_week/BATCH_SIZE) - (Time.now-last_email)
        puts "Sleep debt: " + sleep_debt.to_s
        if sleep_debt > 0
          sleep(sleep_debt)
          sleep_debt = 0
        end
      end
    end
  end

  def self.send_email(n)
    PetitionEmailer.send(n)
    MailerProcessTracker.update
  end
end


EmailScheduler.schedule_email