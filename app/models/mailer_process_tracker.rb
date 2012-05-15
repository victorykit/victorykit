class MailerProcessTracker < ActiveRecord::Base
  attr_accessible :is_locked
  
  def self.in_transaction
    mailer_process = first(:lock => true)
    if !mailer_process.nil? && !mailer_process.is_locked?
      begin
        update_mailer_process(mailer_process, true)
        yield
      rescue => error
        puts "Error in mail process transaction #{error} #{error.backtrace.join}"
      ensure
        update_mailer_process(mailer_process, false)
      end
    end
  end
    
  def self.update_mailer_process(mailer_process, lock)
    mailer_process.is_locked = lock
    mailer_process.save!
  end
end