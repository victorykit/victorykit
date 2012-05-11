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
    @analytics_data.nil? ? 0 : @analytics_data.pageviews.to_i
  end

  def signature_count
    @petition.signatures.count(conditions: ["created_at >= ?", @since_date])
  end

  def conversion_rate
    divide_safe(signature_count.to_f, hit_count.to_f)
  end
  
  def new_member_count
    @petition.signatures.count(conditions: "created_member is true")          
  end
  
  def virality_rate
    divide_safe(new_member_count.to_f, signature_count.to_f)
  end
  
  def divide_safe(numerator, denominator)
    denominator.nonzero? ? numerator / denominator : 0
  end
  
end
