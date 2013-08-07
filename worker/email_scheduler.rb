require 'scheduled_email'
require 'petition_emailer'

WEEK = 60*60*24*7
BATCH_SIZE = 100

class EmailScheduler
  def self.schedule_email
    return if ENV['REALLY_SEND_REAL_EMAILS'] != "1"

    sleep_debt = 0
    max_emails_per_week = Member.active.count.to_f

    process = MailerProcessTracker.new(is_locked: true)
    process.save!

    begin
      while 1
        last_email = Time.now
        amount_sent = PetitionEmailer.send(BATCH_SIZE).length
        process.touch

        if amount_sent.zero?
          sleep_debt = 30
        else
          sleep_debt += WEEK/((max_emails_per_week/MailerProcessTracker.count)/amount_sent) - (Time.now-last_email)
        end

        Rails.logger.info "Sleep debt: #{sleep_debt}, sent: #{amount_sent}"

        $statsd.gauge "email_sleep_debt", sleep_debt

        if amount_sent == 0
          sleep_debt = 30
        end

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

  class << self
    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
    add_transaction_tracer :schedule_email, :category => :task
  end
end


EmailScheduler.schedule_email
