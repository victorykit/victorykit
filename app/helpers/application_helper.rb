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

  def fb_like(url, ref_hash, classes = nil, is_button_count = false)
    attributes = {href: url, send: false, show_faces: false, action: 'like', ref: ref_hash, width: '270'}
    attributes.merge!({layout: 'button_count', width: '100'}) if is_button_count
    tag "fb:like", {data: attributes, class: classes}, false, true
  end

  def google_analytics_tracker petition_id, signature_id
    #TODO: move this to a js file, or a partial?
    analytics_id = Settings.google_analytics.analytics_id
    like_tracker_url = url_for(action: 'new', controller: '/social_tracking', params: {petition_id: petition_id, signature_id: signature_id})
    javascript_tag "var _gaq = _gaq || [];
      _gaq.push(['_setAccount', '#{analytics_id}']);
      _gaq.push(['_trackPageview']);

      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();

      try {
        if (FB && FB.Event && FB.Event.subscribe) {
          FB.Event.subscribe('edge.create', function(targetUrl) {
            _gaq.push(['_trackSocial', 'facebook', 'like', targetUrl]);
            //Google don't export social event data yet, so we have to track social actions as events too
            _gaq.push(['_trackEvent', 'facebook', 'like', targetUrl]);
            $.ajax({
              url: '#{like_tracker_url}'
            });
            $('.tweet').show();
          });
          FB.Event.subscribe('edge.remove', function(targetUrl){
            _gaq.push(['_trackSocial', 'facebook', 'unlike', targetUrl]);
            _gaq.push(['_trackEvent', 'facebook', 'unlike', targetUrl]);
          });
        }
      } catch(e) {}
    "
  end

  def float_to_percentage(f)
    number_to_percentage(f*100, precision: 2)
  end

  def format_date_time(d)
    d.strftime("%Y-%m-%d %H:%M")
  end

  def strip_tags_except_links(text)
    sanitize(text, :tags => %w(a), :attributes => %w(href))
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy)
  end

  def link_to_add_fields(name, f, association, html_options, locals, where)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      locals = {:f => builder}.merge(locals)
      render(association.to_s.singularize + "_fields", locals)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\", \"#{where}\")", html_options)
  end
end
