class Notifications < ActionMailer::Base
  require 'uri'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.signed_petition.subject
  #
  def signed_petition signature
    petition = signature.petition
    @signature = signature
    @petition_link = petition_url(petition, r: signature.member.to_hash)
    @unsubscribe_link = new_unsubscribe_url(Unsubscribe.new, n: signature.member.to_hash)
    email = SignatureEmail.create!(email: signature.member.email, member: signature.member, petition: signature.petition)
    experiments = EmailExperiments.new(email)
    @image_url = experiments.best_image(petition)
    @short_summary = experiments.best_summary(petition)
    @fb_share_url = "https://www.facebook.com/sharer/sharer.php?u=#{petition_url(signature.petition)}?mail_share_ref=#{email.to_hash}"

    to_address = "\"#{signature.full_name}\" <#{signature.email}>"

    if petition.owner && petition.owner.fullname.present?
      from_address = "\"#{petition.owner.fullname}\" <#{ AppSettings.require_keys!("email.from_address") }>"
    else
      from_address = "\"Rootstrikers\" <#{ AppSettings.require_keys!("email.from_address") }>"
    end

    begin
      mail({
        subject: "Thanks for signing '#{signature.petition.title}'",
        to: to_address,
        from: from_address,
        return_path: from_address
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
