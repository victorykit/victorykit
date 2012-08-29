class MailerProcessTracker < ActiveRecord::Base
  attr_accessible :is_locked
  
  def self.in_transaction
    mailer_process = first || create
    check_lock(mailer_process)
    if mailer_process.is_locked?
      put_to_sleep(mailer_process)
      check_lock mailer_process
    end
    unless mailer_process.is_locked?
      begin
        update_mailer_process(mailer_process, true)
        yield
      rescue => error
        Rails.logger.error "Error in mail process transaction #{error} #{error.backtrace.join}"
      ensure
        update_mailer_process(mailer_process, false)
      end
    end
  end

  def self.update
    first.touch
  end
  
  def self.update_mailer_process(mailer_process, lock)
    mailer_process.is_locked = lock
    mailer_process.save!
  end

  def self.create
    return if MailerProcessTracker.count > 0
    super
  end

  def deadlocked?
    updated_at < (4).minutes.ago if updated_at
  end

  private

  def self.check_lock mailer_process
    update_mailer_process(mailer_process, false) if mailer_process.deadlocked?
  end

  def self.put_to_sleep mailer_process
    t = 4.minutes - (Time.now - mailer_process.updated_at)
    nap t if t > 0
  end

  def self.nap sec
    sleep sec
  end 
end