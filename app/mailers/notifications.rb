class Notifications < ActionMailer::Base
	require 'uri'

  default from: Settings.email.from_address
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.signed_petition.subject
  #
  def signed_petition signature
    @petition_link = petition_url(signature.petition)
    @signature = signature
    @unsubscribe_link = URI.join(root_url, 'unsubscribe')
    
    begin
      mail(subject: "Thanks for signing '#{signature.petition.title}'", to: signature.email).deliver
    rescue AWS::SES::ResponseError => e
      Rails.logger.warn e
      if(e.message.match /Address blacklisted/)
        raise "There seems to be a problem with that email address.  Are you sure it's correct?"
      end
    end
  end
  
  def unsubscribed unsubscription
	  @signup_link = URI.join(root_url, 'subscribe')
    mail(subject:"You've successfully unsubscribed", to: unsubscription.email).deliver
  end
end
