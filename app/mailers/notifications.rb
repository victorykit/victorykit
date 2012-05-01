class Notifications < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.signed_petition.subject
  #
  def signed_petition signature
    @greeting = "Hi"
    
    mail subject: I18n.t([:notifications, :signed_petition, :subject], title: "Hello"),   to: "to@example.org"
  end
end
