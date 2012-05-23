class PetitionStatistics
  def initialize(petition, analytics_data, since_date)
    @analytics_data = analytics_data
    @petition = petition
    @since_date = since_date
  end

  def conditions(x=nil)
    s = "created_at >= ?"
    s = x + ' and ' + s if x
    { conditions: [s, @since_date] }
  end
  
  def p; @petition end
  def email_count; p.sent_emails.count(conditions) end
  def opened_emails_count; p.sent_emails.count(conditions: ["was_opened = true"]) end
  #@@BUG should be only opened after @since_date
  def email_signature_count; p.sent_emails.count(conditions("signature_id is not null")) end
  def likes_count; @analytics_data.nil? ? 0 : @analytics_data.likes.to_i end
  def hit_count; @analytics_data.nil? ? 0 : @analytics_data.unique_pageviews.to_i end
  def new_member_count; p.signatures.count(conditions("created_member is true")) end
  
  def open_rate; opened_emails_count/email_count.to_f end
  def sign_rate; email_signature_count/email_count.to_f end
  def like_rate; likes_count/email_count.to_f end
  def hit_rate; hit_count/email_count.to_f end
  def new_rate; new_member_count/email_count.to_f end

  def petition_title; p.title end
  def petition_created_at; p.created_at end
end
