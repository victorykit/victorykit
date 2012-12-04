class UserFeedbackMailer < ActionMailer::Base
  default from: Settings.email.from_address

  def new_message(feedback)
    @feedback = feedback
    mail({
      subject: "Feedback about act.watchdog.net",
      to: "Info <info@watchdog.net>",
      template_name: 'new_message'}).deliver
  end
end
