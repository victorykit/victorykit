class PetitionAnalytics

  def self.all
    analytics_report_data = AnalyticsGateway.get_report_results
    Petition.all.map do |p|    
      petition_path = Rails.application.routes.url_helpers.petition_path(p)
      PetitionAnalytics.new(p, analytics_report_data[petition_path])
    end    
  end
    
  def initialize(petition, analytics_data)
    @analytics_data = analytics_data
    @petition = petition
  end
  
  def hit_count
    @analytics_data.pageviews.to_i
  end

  def signature_count
    @petition.signatures.count
  end

  def conversion_rate
    signature_count.to_f / hit_count.to_f
  end
  
  def new_member_count
    @petition.signatures.count(conditions: "created_member is true")          
  end
  
  def virality_rate
    new_member_count.to_f / signature_count.to_f
  end
  
end
