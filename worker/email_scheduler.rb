require 'scheduled_email'

def schedule_email
  max_emails_per_day = 10000
  while 1
    send_email
    sleep(60*60*24/max_emails_per_day)
  end
end

def send_email
  ScheduledEmail.new_petition(Petition.random, Member.random.email)
end

schedule_email