class AnalyticsGateway
    
  def self.get_report_results
    Rails.cache.fetch("analytics_gateway_report_results", :expires_in => 1.minute) do    
      authorize
      #todo: if not authorize
    
      analytics_id = settings.analytics_id
      profile = Garb::Management::Profile.all.detect { |profile| profile.web_property_id == analytics_id}
      #todo: if not profile
    
      # sets up the query
      report = Garb::Report.new(profile)
      report.dimensions :pagePath
      report.metrics :pageViews    
    
      # executes the query against the analytics service
      results = report.results

      @data = results.reduce({}) { |result, current| result.merge(current.page_path => current)}  
    end
  end 
  
  def self.authorize
    consumer = OAuth::Consumer.new(settings.oauth.user_id, settings.oauth.client_secret,
         {:site => 'https://www.google.com',
         :request_token_path => '/accounts/OAuthGetRequestToken',
         :access_token_path => '/accounts/OAuthGetAccessToken',
         :authorize_path => '/accounts/OAuthAuthorizeToken'})
    
    Garb::Session.access_token = OAuth::AccessToken.new(consumer, settings.oauth.token, settings.oauth.secret)
  end

  def self.settings
    Settings.google_analytics
  end
end
