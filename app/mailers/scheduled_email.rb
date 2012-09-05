class ScheduledEmail < ActionMailer::Base
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduled_email.new_petition.subject
  #

  def new_petition(petition, member)
    SentEmail.transaction do
      begin
        sent_email = log_sent_email(member, petition)
        sent_email_hash = sent_email.to_hash

        @petition = petition
        @member = member
        @petition_link = petition_url(petition, n: sent_email_hash)
        @unsubscribe_link = new_unsubscribe_url(Unsubscribe.new, n: sent_email_hash)
        @tracking_url = new_pixel_tracking_url(n: sent_email_hash)
        @image_url = email_experiment.image_url
        @hide_demand_progress_introduction = email_experiment.demand_progress_introduction
        @ask_to_sign_text = email_experiment.ask_to_sign_text
        @show_button_instead_of_link = email_experiment.show_button_instead_of_link
        headers["List-Unsubscribe"] = "mailto:unsubscribe+" + sent_email_hash + "@appmail.watchdog.net"

        mail(subject: email_experiment.subject, from: email_experiment.sender, to: "\"#{member.full_name}\" <#{member.email}>").deliver
      rescue => exception
        Rails.logger.error "exception sending email: #{exception} #{exception.backtrace.join}"
        raise ActiveRecord::Rollback
      end
    end
  end

  def send_preview(petition, member)
    @petition = petition
    @member = member
    @petition_link = petition.persisted? ? petition_url(petition) : "PETITION LINK GOES HERE"
    @unsubscribe_link = new_unsubscribe_url(Unsubscribe.new)
    @tracking_url = new_pixel_tracking_url
    @image_url = petition.petition_images.any? ? petition.petition_images.first.url : nil
    mail(subject: petition.title, from: Settings.email.from_address, to: "\"#{member.full_name}\" <#{member.email}>", :template_name => 'new_petition').deliver
  end

  private
  def email_experiment
    @email_experiment ||= EmailExperiments.new(@sent_email)
  end

  def log_sent_email(member, petition)
    @sent_email = SentEmail.create!(email: member.email, member: member, petition: petition)
  end
end
