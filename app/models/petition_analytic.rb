class PetitionAnalytic

  def self.all
    analytics_report_data = AnalyticsGateway.get_report_results
    Petition.all.map do |p|    
      petition_path = Rails.application.routes.url_helpers.petition_path(p)
      PetitionAnalytic.new(p, analytics_report_data[petition_path])
    end    
  end

  def self.count
    Petition.count
  end
  
  def self.order(property, direction)
    sorted = all.sort_by(&property.to_sym)
    direction == :asc ? sorted : sorted.reverse
  end
          
  def initialize(petition, analytics_data)
    @analytics_data = analytics_data
    @petition = petition
  end
  
  def petition_title
    @petition.title
  end
  
  def petition_created_at
    @petition.created_at
  end
  
  def hit_count    
    @analytics_data.nil? ? 0 : @analytics_data.pageviews.to_i
  end

  def signature_count
    @petition.signatures.count
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
