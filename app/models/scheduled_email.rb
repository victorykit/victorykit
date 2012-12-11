class ScheduledEmail < SentEmail
  attr_accessible :opened_at, :clicked_at, :signature
  belongs_to :signature

  def already_clicked?
    !self.clicked_at.nil?
  end

  def track_visit!
    self.update_attributes(clicked_at: Time.now) unless already_clicked?
    $statsd.increment "emails_clicked.count"
  end

end
