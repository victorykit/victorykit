class Notifications < ActionMailer::Base
  default from: "signups@victorykit.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.signed_petition.subject
  #
  def signed_petition signature
    @greeting = "Hi"
    
    mail(subject: "Thanks for signing '#{signature.petition.title}'!", to: signature.email).deliver
  end
end
