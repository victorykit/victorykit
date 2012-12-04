class UserFeedbackMailer < ActionMailer::Base
  def new_message(feedback)
    @feedback = feedback
    mail({
      subject: "Feedback about act.watchdog.net",
      from: feedback.email,
      to: "Info <info@watchdog.net>",
      template_name: 'new_message'}).deliver
  end
end
