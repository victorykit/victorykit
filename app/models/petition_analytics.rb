class PetitionAnalytics
  include Rails.application.routes.url_helpers

  def initialize(petition)
    @analytics_data = AnalyticsGateway.get_report_results[petition_path(petition)]
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
