class AnalyticsGateway 

  class Petitions
    extend Garb::Model
    metrics :uniquePageviews
    dimensions :pagePath
  end
  
  class SocialEvents
    extend Garb::Model
    metrics :uniqueEvents
    dimensions :eventCategory, :eventAction, :pagePath
  end

  def self.fetch_report_results(since_date = nil)
    cache_key = "analytics_gateway_report_results"
    #keying by time to the minute effectively expires each minute
    cache_key += "_#{since_date.strftime("%Y%m%d")}"

    Rails.cache.fetch(cache_key, :expires_in => 1.minute) do    
      authorize
    
      analytics_id = settings.analytics_id

      profile = Garb::Management::Profile.all.detect { |profile| profile.web_property_id == analytics_id}
      raise "No profile found for analytics id '#{analytics_id}'. Check settings in your Google Analytics account" if not profile
    
      petition_stats = profile.petitions(start_date: since_date, end_date: Date.today)
      event_stats = profile.social_events(start_date: since_date, end_date: Date.today)

      event_data = event_stats.reduce({}) do |result, current| 
        result.merge(current.page_path => current)
      end
      
      petition_data = petition_stats.reduce({}) do |result, current| 
        result.merge(current.page_path => current)
      end  
      
      petition_data.each do |k, p|
        e = event_data[k]
        p.likes = (!e.nil? && e.event_action == "like") ? e.unique_events : 0
      end
      @data = petition_data
    end
  end 
  
  def self.authorize
    raise "Cannot authorize: missing 'oauth' settings. Run ./script/gen_google_oauth" if settings.oauth.nil?
    
    consumer = OAuth::Consumer.new(settings.oauth.user_id, settings.oauth.client_secret,
         {:site => 'https://www.google.com',
         :request_token_path => '/accounts/OAuthGetRequestToken',
         :access_token_path => '/accounts/OAuthGetAccessToken',
         :authorize_path => '/accounts/OAuthAuthorizeToken'})
    
    #todo: raise error if auth fails
    Garb::Session.access_token = OAuth::AccessToken.new(consumer, settings.oauth.token, settings.oauth.secret)
  end

  def self.settings
    Settings.google_analytics
  end
end
