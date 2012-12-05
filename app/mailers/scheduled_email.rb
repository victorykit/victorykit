class ScheduledEmail < ActionMailer::Base
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduled_email.new_petition.subject
  #

  def new_petition(petition, member)
    begin
      SentEmail.transaction do
        email_record = SentEmail.create!(email: member.email, member: member, petition: petition)
        compose(petition, member, email_record, petition_link(petition, email_record), petition_link(petition, nil)).deliver
      end
    rescue AWS::SES::ResponseError => exception
      handle_aws_ses_error member, exception
    rescue => exception
      record_exception member, exception
    end
  end

  def send_preview(petition, member)
    SentEmail.transaction do
      email_record = SentEmail.new(email: member.email, member: member, petition: petition)
      class <<email_record
        def to_hash
          "preview"
        end
      end
      compose(petition, member, email_record, petition_link(petition, email_record, true), petition_link(petition, nil, true)).deliver
      # always rollback for preview
      raise ActiveRecord::Rollback
    end
  end

  private

  def petition_link petition, email, is_preview=false
    if is_preview and not petition.persisted?
      return "PETITION LINK GOES HERE"
    end
    if email
      return petition_url petition, n: email.to_hash
    else
      return petition_url petition
    end
  end

  def compose(petition, member, email, petition_link, raw_petition_link) 
    #raw_petition_link is the url without the tracking param. There must be a nicer way to do this
    
    email_hash = email.to_hash
    email_experiment = EmailExperiments.new(email)

    @petition = petition
    @member = member
    @petition_link = petition_link

    @unsubscribe_link = new_unsubscribe_url(Unsubscribe.new, n: email_hash)
    @tracking_url = new_pixel_tracking_url(n: email_hash)
    if email_experiment.show_facebook_share_button
      @fb_share_url = "https://www.facebook.com/sharer/sharer.php?u=#{raw_petition_link}?mail_share_ref=#{email_hash}"
    end
    @image_url = email_experiment.image_url
    @ask_to_sign_text = email_experiment.ask_to_sign_text
    @show_ps_with_plain_text = email_experiment.show_ps_with_plain_text
    @show_less_prominent_unsubscribe_link = email_experiment.show_less_prominent_unsubscribe_link
    @short_summary = email_experiment.petition_short_summary
    @font_size_of_petition_link = "font-size:#{email_experiment.font_size_of_petition_link};"
    @button_color = "background:#{email_experiment.button_color_for_petition_link};"
    @share_button_color = "background:#{email_experiment.button_color_for_share_petition_link};" #TODO: different colors for share button?
    headers["List-Unsubscribe"] = "mailto:unsubscribe+" + email_hash + "@appmail.watchdog.net"

    mail = mail(
      subject: email_experiment.subject,
      from: email_experiment.from_address,
      to: "\"#{member.full_name}\" <#{member.email}>",
      template_name: 'new_petition')
  end

  def handle_aws_ses_error member, exception
    if exception.message.match /(MessageRejected - Address blacklisted|InvalidParameterValue)/
      u = Unsubscribe.unsubscribe_member(member)
      u.cause = "#{exception.class}: #{exception.message}"
      u.save!
    else
      record_exception member, exception
    end
  end

  def record_exception member, exception
    Airbrake.notify(exception)
    Rails.logger.error "exception sending email: #{exception} #{exception.backtrace.join}"
    EmailError.create!(member: member, email: member.email, error: exception)
  end

end
