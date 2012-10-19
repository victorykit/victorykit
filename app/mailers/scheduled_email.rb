class ScheduledEmail < ActionMailer::Base
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduled_email.new_petition.subject
  #

  def new_petition(petition, member)
    SentEmail.transaction do
      begin
        email_record = SentEmail.create!(email: member.email, member: member, petition: petition)
        compose(petition, member, email_record, petition_link(petition, email_record)).deliver
      rescue => exception
        Airbrake.notify(exception)
        Rails.logger.error "exception sending email: #{exception} #{exception.backtrace.join}"
        raise ActiveRecord::Rollback
      end
    end
  end

  def send_preview(petition, member)
    SentEmail.transaction do
      begin
        email_record = SentEmail.new(email: member.email, member: member, petition: petition)
        class <<email_record
          def to_hash
            "preview"
          end
        end
        compose(petition, member, email_record, petition_link(petition, email_record, true)).deliver
        # always rollback for preview
        raise ActiveRecord::Rollback
      end
    end
  end

  private

  def petition_link petition, email, is_preview=false
    if is_preview and not petition.persisted?
      return "PETITION LINK GOES HERE"
    end
    return petition_url petition, n: email.to_hash
  end

  def compose petition, member, email, petition_link
    email_hash = email.to_hash
    email_experiment = EmailExperiments.new(email)

    @petition = petition
    @member = member
    @petition_link = petition_link

    @unsubscribe_link = new_unsubscribe_url(Unsubscribe.new, n: email_hash)
    @tracking_url = new_pixel_tracking_url(n: email_hash)
    @image_url = email_experiment.image_url
    @hide_demand_progress_introduction = email_experiment.hide_demand_progress_intro?
    @demand_progress_introduction_location = email_experiment.demand_progress_introduction_location
    @ask_to_sign_text = email_experiment.ask_to_sign_text
    @box_location = email_experiment.box_location
    @show_ps_with_plain_text = email_experiment.show_ps_with_plain_text
    @show_less_prominent_unsubscribe_link = email_experiment.show_less_prominent_unsubscribe_link
    @font_size_of_petition_link = "font-size:#{email_experiment.font_size_of_petition_link};"
    @button_color = "background:#{email_experiment.button_color_for_petition_link};"
    headers["List-Unsubscribe"] = "mailto:unsubscribe+" + email_hash + "@appmail.watchdog.net"

    mail = mail(
      subject: email_experiment.subject,
      from: Settings.email.from_address,
      to: "\"#{member.full_name}\" <#{member.email}>",
      template_name: 'new_petition')
  end

end
