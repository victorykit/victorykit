require 'scheduled_email'
require 'petition_emailer'

WEEK = 60*60*24*7
BATCH_SIZE = 100

class EmailScheduler
  class << self
     include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
     add_transaction_tracer :schedule_email, :category => :task
  end

  def self.schedule_email
    return if ENV['REALLY_SEND_REAL_EMAILS'] != "1"

    sleep_debt = 0
    max_emails_per_week = Member.count.to_f
    
    process = MailerProcessTracker.new(is_locked: true)
    process.save!

    begin
      while 1
        last_email = Time.now
        amount_sent = PetitionEmailer.send(BATCH_SIZE).length
        process.touch

        sleep_debt += WEEK/((max_emails_per_week/MailerProcessTracker.count)/amount_sent) - (Time.now-last_email)
        puts "Sleep debt: " + sleep_debt.to_s

        if sleep_debt > 0
          sleep(sleep_debt)
          sleep_debt = 0
        end
      end
    rescue => error
      Airbrake.notify(error)
      Rails.logger.error "Error in mail process transaction #{error} #{error.backtrace.join}"
    ensure
      process.delete
    end
  end
end


EmailScheduler.schedule_email