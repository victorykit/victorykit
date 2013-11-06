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

  def configure_google_analytics
    analytics_id = Settings.google_analytics.analytics_id
    javascript_tag "var _gaq = _gaq || [];
      _gaq.push(['_setAccount', '#{analytics_id}']);
      _gaq.push(['_trackPageview']);
      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();"
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

  def should_spin_petition_options?
    #current_page?(controller: 'petitions', action: 'show', id: params[:id])# && !( !current_user.nil? && ( current_user.is_admin? || current_user.is_super_user? ) )
    params[:controller] == 'petitions' && params[:action] == 'show' && !(!current_user.nil? && (current_user.is_admin? || current_user.is_super_user?))
  end

  def social_media_config
    Rails.configuration.social_media
  end

  def facebook_namespace
    social_media_config[:facebook][:namespace]
  end
end
