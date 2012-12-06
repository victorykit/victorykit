class Notifications < ActionMailer::Base
  include PersistedExperiments
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
    @image_url = best_image(petition)
    @short_summary = best_summary(petition)
    referral = ReferralCode.new(petition: petition, member: signature.member)
    referral.save
    @fb_share_url = "https://www.facebook.com/sharer/sharer.php?u=#{petition_url(signature.petition)}?mail_share_ref=#{referral.code}"

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

  private

  def best_image petition
    experiment = "petition #{petition.id} image" 
    options = petition.petition_images.map(&:url)
    unless options.empty?
      url = winning_option(experiment, options)
      url ? PetitionImage.find_by_url(url).public_url : url
    end
  end

  def best_summary petition
    experiment = "petition #{petition.id} email short summary"
    options = petition.petition_summaries.map(&:short_summary)
    winning_option(experiment, options) unless options.empty? 
  end

end
