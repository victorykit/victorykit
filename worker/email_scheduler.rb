require 'scheduled_email'
require 'whiplash'

class EmailScheduler
  extend Bandit
  
  def self.schedule_email
    max_emails_per_day = 10000
    while 1
      send_email
      sleep(60*60*24/max_emails_per_day)
    end
  end

  def self.send_email
    member = get_member_to_email
    if not member.nil?
      petition_id = spin!("email_scheduler", :signups_off_email, options=Petition.all.map {|x| x.id.to_s}, {session_id: member.id}).to_i
      petition = Petition.find_by_id(petition_id)
      sent_email_id = log_sent_email(member, petition)
      ScheduledEmail.new_petition(petition, member.email, sent_email_id)
    else
      #puts "No more people to email."
    end
  end

  def self.get_member_to_email
    q = Member.connection.execute("SELECT members.id FROM members LEFT JOIN sent_emails ON (members.id = sent_emails.member_id AND sent_emails.created_at > now() - interval '1 month') WHERE sent_emails.member_id is null").to_a
    q.empty? ? nil : Member.find_by_id(q.to_a.sample['id'])
  end

  def self.log_sent_email(member, petition)
    sentEmail = SentEmail.new(email: member.email, member: member, petition: petition)
    sentEmail.save!
    sentEmail.id
  end
end

EmailScheduler.schedule_email