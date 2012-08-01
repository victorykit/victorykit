require 'sent_email_hasher'

class ScheduledEmail < ActionMailer::Base
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduled_email.new_petition.subject
  #

  def new_petition(petition, member)
    sent_email_id = log_sent_email(member, petition)
    sent_email_hash = SentEmailHasher.generate(sent_email_id)
    link_request_params = "?n=" + sent_email_hash

    @petition_link = petition_url(petition) + link_request_params
    @unsubscribe_link = new_unsubscribe_url(Unsubscribe.new) + link_request_params
    @tracking_url = new_pixel_tracking_url + link_request_params
    @petition = petition
    @member = member
    headers["List-Unsubscribe"] = "mailto:unsubscribe+" + sent_email_hash + "@appmail.watchdog.net"
    setup_experiments
    mail(subject: email_experiment.subject, from: email_experiment.sender, to: "\"#{member.name}\" <#{member.email}>").deliver
  end

  def send_preview(petition, member)
    @petition = petition
    @is_summary_present = petition.short_summary.present?
    @member = member
    @petition_link = petition.persisted? ? petition_url(petition) : "PETITION LINK GOES HERE"
    @unsubscribe_link = new_unsubscribe_url(Unsubscribe.new)
    @tracking_url = new_pixel_tracking_url
    @image_url = petition.petition_images.any? ? petition.petition_images.first.url : nil
    mail(subject: petition.title, from: Settings.email.from_address, to: "\"#{member.name}\" <#{member.email}>", :template_name => 'new_petition').deliver
  end

  private 

  def setup_experiments
    @hide_demand_progress_introduction = email_experiment.demand_progress_introduction
    @image_url = email_experiment.image_url
    @is_summary_present = @petition.short_summary.present? ? email_experiment.summary_box : false
  end

  def email_experiment
    @email_experiment ||= EmailExperiments.new(@sent_email)
  end

  def log_sent_email(member, petition)
    @sent_email = SentEmail.new(email: member.email, member: member, petition: petition)
    @sent_email.save!
    @sent_email.id
  end
end
