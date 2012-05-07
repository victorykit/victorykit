require 'scheduled_email'
require 'whiplash'

class EmailScheduler
  extend Bandit
  
  def self.schedule_email
    max_emails_per_day = 10000
    mailer_process = MailerProcessTracker.find_by_id(1)
    while 1
      #Lock table
      #x = MailerProcessTracker.connection.execute("SELECT * FROM mailer_process_trackers WHERE mailer_process_trackers.id = 1").to_a 
      #ActiveRecord::Base.connection.execute("LOCK TABLES users WRITE")
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
      sleep(60*60*24/max_emails_per_day)
    end
  end

  def self.send_email
    member = get_member_to_email
    if not member.nil?
      petition_id = spin!("email_scheduler", :signups_off_email, options=Petition.find_all_by_to_send(true).map {|x| x.id.to_s}, {session_id: member.id}).to_i
      petition = Petition.find_by_id(petition_id)
      sent_email_id = log_sent_email(member, petition)
      ScheduledEmail.new_petition(petition, member.email, sent_email_id)
    else
      #puts "No more people to email."
    end
  end

  def self.get_member_to_email
    q = Member.connection.execute("SELECT members.id FROM members LEFT JOIN sent_emails ON (members.id = sent_emails.member_id AND sent_emails.created_at > now() - interval '1 month') WHERE sent_emails.member_id is null").to_a
    q.empty? ? nil : Member.find_by_id(q.sample['id'])
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