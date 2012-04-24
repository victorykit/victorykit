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

  def facebook_like(url)
    content_tag :iframe, nil, :src => 
      "http://www.facebook.com/plugins/like.php?href=#{CGI::escape(url)}&layout=button_count&action=recommend&show_faces=true&width=450&height=80&font=arial&colorscheme=light", 
      :scrolling => 'no', :frameborder => '0', :allowtransparency => true, :id => :facebook_like
  end
  
end
