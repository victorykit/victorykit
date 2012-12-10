class AnalyticsObserver < ActiveRecord::Observer
  observe :signature, :unsubscribe, :sent_email, :facebook_action

  def after_create(record)
    stat_name = case record
    when Signature
      "signatures.count"
    when Unsubscribe
      "unsubscribes.count"
    when ScheduledEmail
      "emails_sent.count"
    when FacebookAction
      "facebook_actions.count"
    end

    $statsd.increment stat_name
    $statsd.increment "members_joined.count" if record.is_a?(Signature) && record.created_member?
  end
end
