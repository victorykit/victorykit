require 'scheduled_email'

def schedule_email
  max_emails_per_day = 10000
  while 1
    send_email
    sleep(60*60*24/max_emails_per_day)
  end
end

def send_email
  member = Member.random
  petition = Petition.random
  ScheduledEmail.new_petition(petition, member.email)
  sentEmail = SentEmail.new(email: member.email, member: member, petition: petition)
  sentEmail.save!
end

schedule_email