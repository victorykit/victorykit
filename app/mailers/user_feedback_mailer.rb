class UserFeedbackMailer < ActionMailer::Base
  def new_message(feedback)
    @feedback = feedback

    mail(
      from: "#{feedback.name} <#{Settings.site.email}>",
      subject: "Feedback from #{feedback.email || feedback.name || 'anon'} about #{Settings.site.name}",
      to: Settings.site.feedback_email,
      template_name: 'new_message'
    ).deliver
  end
end
