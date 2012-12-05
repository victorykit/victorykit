class UserFeedbackMailer < ActionMailer::Base
  def new_message(feedback)
    @feedback = feedback
    mail({
      from: "#{feedback.name} <info@watchdog.net>",
      subject: "Feedback from #{feedback.email || feedback.name || 'anon'} about act.watchdog.net",
      to: "me+watchdog@aaronsw.com",
      template_name: 'new_message'}).deliver
  end
end
