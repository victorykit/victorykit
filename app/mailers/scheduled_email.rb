require 'hasher'
class ScheduledEmail < ActionMailer::Base
  default from: "jensmith@thoughtworks.com",
          return_path: 'mdsouza@thoughtworks.com'
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduled_email.new_petition.subject
  #
  def new_petition(petition, email, sent_email_id)
    @petition_link = petition_url(petition) + "?n=" + Hasher.generate(sent_email_id)
    @unsubscribe_link = new_unsubscribe_url(Unsubscribe.new)
    @petition = petition
    msg_id = Hasher.generate(sent_email_id) + "@watchdog.net"
    
    mail(:message_id => msg_id, subject: "New Petition: '#{petition.title}'!", to: email).deliver
  end
end
