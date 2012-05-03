require 'hasher'
class ScheduledEmail < ActionMailer::Base
  default from: "jensmith@thoughtworks.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.signed_petition.subject
  #
  def new_petition(petition, email, sent_email_id)
    @petition_link = petition_url(petition) + "?n=" + Hasher.generate(sent_email_id)
    @petition = petition
    
    mail(subject: "New Petition: '#{petition.title}'!", to: email).deliver
  end
end
