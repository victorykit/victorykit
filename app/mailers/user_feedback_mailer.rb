class UserFeedbackMailer < ActionMailer::Base
  def new_message(feedback)
    @feedback = feedback

    site_email, site_name, site_feedback = AppSettings.require_keys!(
      "site.email", "site.name", "site.feedback_email"
    )

    mail(
      from: "#{feedback.name} <#{site_email}>",
      subject: "Feedback from #{feedback.email || feedback.name || 'anon'} about #{site_name}",
      to: site_feedback,
      template_name: 'new_message'
    ).deliver
  end
end
