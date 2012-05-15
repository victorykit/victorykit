require 'scheduled_email'
require 'whiplash'

class EmailScheduler
  extend Bandit
  
  def self.schedule_email
    max_emails_per_day = 10000
    
    while 1
      MailerProcessTracker.transaction do
        mailer_process = MailerProcessTracker.find_by_id(1, :lock => true)
        if !mailer_process.nil? && !mailer_process.is_locked?
          begin
            update_mailer_process(mailer_process, true)
            send_email
          rescue => error
            puts "Error in sending mail #{error} #{error.backtrace.join}"
          ensure
            update_mailer_process(mailer_process, false)
          end
        end
      end
      sleep(60*60*24/max_emails_per_day)
    end
  end

  def self.send_email
    member = Member.random_and_not_recently_contacted
    if not member.nil?
      petition_id = spin!("email_scheduler", :signups_off_email, options=Petition.find_interesting_petitions_for(member).map {|x| x.id.to_s}, {session_id: member.id}).to_i
      petition = Petition.find_by_id(petition_id)
      sent_email_id = log_sent_email(member, petition)
      ScheduledEmail.new_petition(petition, member.email, sent_email_id)
    end
  end

  def self.log_sent_email(member, petition)
    sentEmail = SentEmail.new(email: member.email, member: member, petition: petition)
    sentEmail.save!
    sentEmail.id
  end
  
  def self.update_mailer_process(mailer_process, lock)
    mailer_process.is_locked = lock
    mailer_process.save!
  end
end

EmailScheduler.schedule_email