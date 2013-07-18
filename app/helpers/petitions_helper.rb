module PetitionsHelper

  def open_graph_for(petition, referral)
    {
      'og:title' => referral.title,
      'og:type' => 'watchdognet:petition',
      'og:description' => referral.facebook_description_for_sharing.html_safe,
      'og:image' => referral.image,
      'og:site_name' => social_media_config[:facebook][:site_name]
    } # you must be asking: where is fb:app_id? that's in the base layout.
  end

  def counter_size(signature_count)
    [  5,     10,     50,     100,
      250,   500,    750,    1000,
     2000,  5000,   7500,   10000,
    15000, 20000, 100000, 1000000].
    find { |n| signature_count < n }
  end

  def choose_form_based_on_browser
    really_ie? ? 'ie_form' : 'form'
  end

  def facebook_sharing_option
    @facebook_sharing_option ||= FacebookSharingOptionsExperiment.new(self).spin! @member, browser
  end

  def facebook_button
    button_hash = {
      'facebook_share' => { button_class: 'fb_share', button_text: 'Share on Facebook' },
      'facebook_popup' => { button_class: 'fb_popup_btn', button_text: 'Share on Facebook' },
      'facebook_dialog' => { button_class: 'fb_dialog_btn', button_text: 'Share on Facebook' },
      'facebook_request' => { button_class: 'fb_request_btn', button_text: 'Send request to friends' },
      'facebook_recommendation' => { button_class: 'fb_recommend_btn', button_text: 'Send to friends' },
    }
    button_hash[facebook_sharing_option] || button_hash['facebook_popup']
  end

  def fb_like(url, ref_code, classes = nil, is_button_count = false)
    url = ref_code ? "#{url}?f=#{ref_code}" : url
    attributes = {href: url, send: false, show_faces: false, action: 'like', width: '270'}
    attributes.merge!({layout: 'button_count', width: '100'}) if is_button_count
    tag "fb:like", {data: attributes, class: classes}, false, true
  end

  def after_share_view(sigcount)
    return after_share_view_under_10k if sigcount < 10000
    measure! 'after share view 8', :share, [
       "button_is_most_effective_tool-progress_bar",
       "almost_finished_only_one_thing_left_to_do",
       "almost_there_only_one_thing_left_to_do-bottom_arrow",
       "almost_there_only_one_thing_left_to_do-85_bottom_arrow"
    ]
  end

  def after_share_view_under_10k
    measure! 'after share view under 10k', :share, [
      "button_is_most_effective_tool-progress_bar",
      "almost_finished_only_one_thing_left_to_do",
      "almost_there_only_one_thing_left_to_do-bottom_arrow",
      "almost_there_only_one_thing_left_to_do-85_bottom_arrow",
      "can_you_help_us_reach_10k",
      "button_is_most_effective_to_10k",
      "button_is_going_to_get_us_to_10k"
    ]
  end

  def under_10k_message
    spin! 'under 10k messaging', :signature, ["10k_message", "default"]
  end

  def learn_more_button_color
    spin! 'learn more button color', :signature, ["grey", "blue", "link"]
  end

  def accent_red
    measure!('toggle red for buttons and progress bar',
      :signature, ['bright_red', 'dull_red', 'dark_red'])
  end

  def x_of_y_styling
    measure! 'styling of x signatures of y (measure)', :signature, [
      'plain',
      'bold',
      'large_and_bold'
    ]
  end

  def progress_box_border
    spin! 'toggle border of progress box', :signature, [
      'red-unbordered',
      'red-bordered'
    ]
  end

  def privacy_text
    return 'original' if browser.mobile?
    measure! 'change privacy policy text 2', :signature, [
      'tooltip',
      'short',
      'short_never-share_just-permission',
      'short_just-permission',
      'short_never-share',
      'short_our-campaigns',
      'short_never-share_our-campaigns',
      'original',
      'long'
    ]
  end

  def privacy_policy_position_and_color
    return 'inside_aaa' if browser.mobile?
    spin! 'change privacy policy position relative to sign box and color on petition page', :signature, ['inside_ccc', 'inside_aaa', 'inside_888', 'outside_ccc', 'outside_aaa', 'outside_888']
  end

  def sign_petition_option
    #spin! 'test different ways to sign and share', :share, ['just_sign', 'sign_and_share']
    'just_sign'
  end

  private

  def really_ie?
    browser.ie? && !(browser.user_agent =~ /chromeframe/)
  end

  def social_media_config
    Rails.configuration.social_media
  end

end
