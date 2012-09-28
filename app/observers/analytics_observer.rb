class AnalyticsObserver < ActiveRecord::Observer
  observe :signature, :unsubscribe, :sent_email

  def after_create(record)
    stat_name = case record
    when Signature
      "signatures"
    when Unsubscribe
      "unsubscribes"
    when SentEmail
      "emails_sent"
    end

    $statsd.increment stat_name
    $statsd.increment "members_joined" if record.is_a?(Signature) && record.created_member?
  end
end