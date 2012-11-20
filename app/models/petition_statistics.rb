class PetitionStatistics
  def initialize(petition, analytics_data, local_stats)
    @analytics_data = analytics_data
    @petition = petition
    @local_stats = local_stats
  end
  def p; @petition end
  def email_count; @local_stats.sent_emails end
  def opened_emails_count; @local_stats.opened_emails end
  def clicked_emails_count; @local_stats.clicked_emails end
  def signature_count; @local_stats.signatures end
  def email_signature_count; @local_stats.signed_from_emails end
  def hit_count; @analytics_data.nil? ? 0 : @analytics_data.unique_pageviews.to_i end
  def new_member_count; @local_stats.new_members end
  def unsubscribe_count; @local_stats.unsubscribes end
  def open_rate; divide_safe(opened_emails_count, email_count) end
  def clicked_rate; divide_safe(clicked_emails_count, email_count) end
  def sign_rate; divide_safe(email_signature_count, email_count) end
  def like_rate; divide_safe(likes_count, email_count) end
  def hit_rate; divide_safe(hit_count, email_count) end
  def new_rate; divide_safe(new_member_count, email_count) end
  def unsub_rate; divide_safe(unsubscribe_count, email_count) end
  def petition_title; p.title end
  def petition_created_at; p.created_at end
  def divide_safe(numerator, denominator)
    denominator.nonzero? ? numerator / denominator.to_f : 0.0
  end

  def likes_count
    Like.where(:petition_id => p).count
  end

end
