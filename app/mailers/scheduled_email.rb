require 'hasher'
class ScheduledEmail < ActionMailer::Base
  default from: Settings.email.from_address
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduled_email.new_petition.subject
  #
  def new_petition(petition, member)
    sent_email_id = log_sent_email(member, petition)
    sent_email_hash = Hasher.generate(sent_email_id)
    @petition_link = petition_url(petition) + "?n=" + sent_email_hash
    @unsubscribe_link = new_unsubscribe_url(Unsubscribe.new)
    @petition = petition
    @member = member
    return_path = "bounce-" + sent_email_hash + "@appmail.watchdog.net"
    
    mail(return_path: return_path, subject: petition.title, to: "#{member.name} <#{member.email}>").deliver
  end
    
  def log_sent_email(member, petition)
    sentEmail = SentEmail.new(email: member.email, member: member, petition: petition)
    sentEmail.save!
    sentEmail.id
  end
end
