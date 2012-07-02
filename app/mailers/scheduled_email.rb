require 'sent_email_hasher'
require 'whiplash'

class ScheduledEmail < ActionMailer::Base
  default from: Settings.email.from_address
  helper_method :spin!
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
    return_path = "bounce+" + sent_email_hash + "@appmail.watchdog.net"
    subject = spin_subject petition
    headers["List-Unsubscribe"] = "mailto:unsubscribe+" + sent_email_hash + "@appmail.watchdog.net"
    mail(return_path: return_path, subject: subject, to: "\"#{member.name}\" <#{member.email}>").deliver
  end

  def spin(test_name, goal, options)
    return EmailSpinner.new.do_spin! @sent_email, test_name, goal, options
  end

  private 

  def spin_subject petition
    options = PetitionTitle.find_all_by_petition_id_and_title_type(petition.id, PetitionTitle::TitleType::EMAIL)
    choice = spin("petition #{petition.id} email title", :signature, options.map{|opt| opt.text}) if options.any?
    choice || petition.title
  end

  def log_sent_email(member, petition)
    @sent_email = SentEmail.new(email: member.email, member: member, petition: petition)
    @sent_email.save!
    @sent_email.id
  end
end
