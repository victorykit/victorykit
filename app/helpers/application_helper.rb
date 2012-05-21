require 'rails_rinku'
module ApplicationHelper
  def twitterized_type(type)
    case type
      when :alert
        "alert"
      when :error
        "alert-error"
      when :notice
        "alert-info"
      when :success
        "alert-success"
      else
        type.to_s
    end
  end

  def google_analytics_tracker
    analytics_id = Settings.google_analytics.analytics_id
    javascript_tag "var _gaq = _gaq || [];
      _gaq.push(['_setAccount', '#{analytics_id}']);
      _gaq.push(['_trackPageview']);

      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();
      
      if (FB && FB.Event && FB.Event.subscribe) {
        FB.Event.subscribe('edge.create', function(targetUrl) {
          _gaq.push(['_trackSocial', 'facebook', 'like', targetUrl]);
        });
      }"
  end

  def float_to_percentage(f)
    number_to_percentage(f*100, precision: 2)
  end

  def format_date_time(d)
    d.strftime("%Y-%m-%d %H:%M")
  end
end
