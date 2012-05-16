class AnalyticsGateway 
  def self.fetch_report_results(since_date = nil)
    cache_key = "analytics_gateway_report_results"
    #keying by time to the minute effectively expires each minute
    cache_key += "_#{since_date.strftime("%Y%m%d")}"

    Rails.cache.fetch(cache_key, :expires_in => 1.minute) do    
      authorize
      #todo: if not authorize
    
      analytics_id = settings.analytics_id
      profile = Garb::Management::Profile.all.detect { |profile| profile.web_property_id == analytics_id}
      #todo: if not profile
    
      # sets up the query
      report = Garb::Report.new(profile, :start_date => since_date, :end_date => Date.today)
      report.dimensions :pagePath
      report.metrics :uniquePageviews    
    
      # executes the query against the analytics service
      results = report.results

      @data = results.reduce({}) do |result, current| 
        result.merge(current.page_path => current)
      end  
    end
  end 
  
  def self.authorize
    #todo move check to status page
    raise "Cannot authorize: missing 'oauth' settings.  scripts/gen_google_auth" if settings.oauth.nil?
    
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
