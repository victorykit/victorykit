class ScheduledEmail < ActionMailer::Base
  default from: "jensmith@thoughtworks.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.signed_petition.subject
  #
  def new_petition(petition, email)
    @petition_link = petition_url(petition)
    @petition = petition
    
    mail(subject: "New Petition: '#{petition.title}'!", to: email).deliver
    puts "Delivered!"
  end
end
