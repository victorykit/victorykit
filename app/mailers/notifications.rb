class Notifications < ActionMailer::Base
  default from: Settings.email.from_address
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.signed_petition.subject
  #
  def signed_petition signature
    @petition_link = petition_url(signature.petition)
    @signature = signature
    @unsubscribe_link = new_unsubscribe_url(Unsubscribe.new)
    
    mail(subject: "Thanks for signing '#{signature.petition.title}'!", to: signature.email).deliver
  end
  
  def unsubscribed unsubscription
    mail(subject:"You've successfully unsubscribed", to: unsubscription.email).deliver
  end
end
