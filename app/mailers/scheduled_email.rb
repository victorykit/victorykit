require 'hasher'
class ScheduledEmail < ActionMailer::Base
  default from: Settings.email.from_address
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduled_email.new_petition.subject
  #
  def new_petition(petition, email, sent_email_id)
    @petition_link = petition_url(petition) + "?n=" + Hasher.generate(sent_email_id)
    @unsubscribe_link = new_unsubscribe_url(Unsubscribe.new)
    @petition = petition
    return_path = "bounce-" + Hasher.generate(sent_email_id) + "@appmail.watchdog.net"
    
    mail(return_path: return_path, subject: "New Petition: '#{petition.title}'!", to: email).deliver
  end
end
