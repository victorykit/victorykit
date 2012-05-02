class AnalyticsGateway
    
  def self.get_report_results    
    authorize
    #todo: if not authorize
    
    analytics_id = Rails.configuration.social_media[:google][:analytics_id]
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
  
  def self.authorize
    oauth_user_id = ENV["OAUTH_USER_ID"]
    oauth_client_secret = ENV["OAUTH_CLIENT_SECRET"]
    oauth_token = ENV["OAUTH_TOKEN"]
    oauth_secret = ENV["OAUTH_SECRET"]

    consumer = OAuth::Consumer.new(oauth_user_id, oauth_client_secret,
         {:site => 'https://www.google.com',
         :request_token_path => '/accounts/OAuthGetRequestToken',
         :access_token_path => '/accounts/OAuthGetAccessToken',
         :authorize_path => '/accounts/OAuthAuthorizeToken'})
    
    Garb::Session.access_token = OAuth::AccessToken.new(consumer, oauth_token, oauth_secret)
  end
  
end