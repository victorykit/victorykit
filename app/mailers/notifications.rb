class Notifications < ActionMailer::Base
  require 'uri'

  default from: Settings.email.from_address
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.signed_petition.subject
  #
  def signed_petition signature
    petition = signature.petition
    @signature = signature
    @petition_link = petition_url(petition, r: signature.member.to_hash)
    @unsubscribe_link = URI.join(root_url, 'unsubscribe')
    email = SignatureEmail.create!(email: signature.member.email, member: signature.member, petition: signature.petition)
    experiments = EmailExperiments.new(email)
    @image_url = experiments.best_image(petition)
    @short_summary = experiments.best_summary(petition)
    @fb_share_url = "https://www.facebook.com/sharer/sharer.php?u=#{petition_url(signature.petition)}?mail_share_ref=#{email.to_hash}"

    begin
      mail({
        subject: "Thanks for signing '#{signature.petition.title}'", 
        to: signature.email
      }).deliver

    rescue AWS::SES::ResponseError => e
      Rails.logger.warn e
      if(e.message.match(/Address blacklisted/))
        raise "There seems to be a problem with that email address.  Are you sure it's correct?"
      end
    end
  end
  
  def unsubscribed unsubscription
    @signup_link = URI.join(root_url, 'subscribe')
    mail({
      subject:"You've successfully unsubscribed",
      to: unsubscription.email
    }).deliver
  end
end
