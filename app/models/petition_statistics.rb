class PetitionStatistics

  def self.count
    Petition.count
  end
          
  def initialize(petition, analytics_data, since_date)
    @analytics_data = analytics_data
    @petition = petition
    @since_date = since_date
  end
  
  def petition_title
    @petition.title
  end
  
  def petition_record
    @petition
  end
  
  def petition_created_at
    @petition.created_at
  end
  
  def hit_count    
    @analytics_data.nil? ? 0 : @analytics_data.unique_pageviews.to_i
  end

  def signature_count
    @petition.signatures.count(conditions: ["created_at >= ?", @since_date])
  end

  def conversion_rate
    divide_safe(signature_count.to_f, hit_count.to_f)
  end
  
  def new_member_count
    @petition.signatures.count(conditions: ["created_member is true and created_at >= ?", @since_date])          
  end
  
  def virality_rate
    divide_safe(new_member_count.to_f, signature_count.to_f)
  end
  
  def divide_safe(numerator, denominator)
    denominator.nonzero? ? numerator / denominator : 0
  end
  
  def email_count
    @petition.sent_emails.count(conditions: ["created_at >= ?", @since_date])
  end

  def opened_emails_count
    @petition.sent_emails.count(conditions: ["was_opened = true"])
  end

  def opened_emails_percentage
    divide_safe(opened_emails_count.to_f, email_count.to_f)
  end

  def email_signature_count
    @petition.sent_emails.count(conditions: ["signature_id is not null and created_at >= ?", @since_date])
  end

  def email_conversion_rate
    divide_safe(email_signature_count.to_f, email_count.to_f)
  end  
  
  def likes
    @analytics_data.nil? ? 0 : @analytics_data.likes.to_i
  end
  
  def likes_percentage
    @analytics_data.nil? ? 0 : divide_safe(@analytics_data.likes.to_f, hit_count.to_f)
  end
end
