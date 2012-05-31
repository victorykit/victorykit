require 'hasher'
require 'whiplash'

class ScheduledEmail < ActionMailer::Base
  include Bandit
  default from: Settings.email.from_address
  helper_method :spin!
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduled_email.new_petition.subject
  #

  def new_petition(petition, member)
    sent_email_id = log_sent_email(member, petition)
    sent_email_hash = Hasher.generate(sent_email_id)
    @petition_link = petition_url(petition) + "?n=" + sent_email_hash
    @unsubscribe_link = new_unsubscribe_url(Unsubscribe.new) + "?n=" + sent_email_hash
    @tracking_url = new_pixel_tracking_url + "?n=" + sent_email_hash
    @petition = petition
    @member = member
    return_path = "bounce+" + sent_email_hash + "@appmail.watchdog.net"
    headers["List-Unsubscribe"] = "mailto:unsubscribe+" + sent_email_hash + "@appmail.watchdog.net"
    mail(return_path: return_path, subject: petition.title, to: "\"#{member.name}\" <#{member.email}>").deliver
  end

  def spin!(test_name, goal, options)
    session = {:session_id => @sent_email.id.to_s}
    choice = super(test_name, goal, options, session)
    add_spin_data goal, test_name, choice
    return choice
  end

  private 

  def add_spin_data goal, test_name, choice
    experiment = EmailExperiment.new
    experiment.sent_email_id = @sent_email.id
    experiment.goal = goal
    experiment.key = test_name
    experiment.choice = choice
    experiment.save!
  end

  private 

  def log_sent_email(member, petition)
    @sent_email = SentEmail.new(email: member.email, member: member, petition: petition)
    @sent_email.save!
    @sent_email.id
  end
end
