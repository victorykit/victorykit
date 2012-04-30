class AnalyticsGateway
  
  def self.get_report_results    

    #todo: use OAuth
    #Garb::Session.login('', '')

    analytics_id = Rails.configuration.social_media[:google][:analytics_id]
    profile = Garb::Management::Profile.all.detect { |profile| profile.web_property_id == analytics_id}
    
    # sets up the query
    report = Garb::Report.new(profile)
    report.dimensions :pagePath
    report.metrics :pageViews    
    
    # executes the query
    results = report.results

    results.reduce({}) { |result, current| result.merge(current.page_path => current)}  
  end 
  
end