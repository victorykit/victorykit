module PetitionsHelper

  def open_graph_for(petition, referral_code)
    {
      'og:title' => referral_code.title,
      'og:type' => 'watchdognet:petition',
      'og:description' => petition.facebook_description_for_sharing.html_safe,
      'og:image' => referral_code.image,
      'og:site_name' => social_media_config[:facebook][:site_name],
      'fb:app_id' => social_media_config[:facebook][:app_id]
    }
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
    return 'facebook_popup' if browser.ie7?
    options = ['facebook_popup', 'facebook_request', 'facebook_recommendation', 'facebook_dialog']
    winner =  spin! 'facebook sharing options', :referred_member, options
    (winner == 'facebook_request') ? facebook_request_pick_vs_autofill : winner
  end

  def facebook_button
    button_hash = {
      'facebook_share' => { button_class: 'fb_share', button_text: 'Share on Facebook' },
      'facebook_popup' => { button_class: 'fb_popup_btn', button_text: 'Share on Facebook' },
      'facebook_dialog' => { button_class: 'fb_dialog_btn', button_text: 'Share on Facebook' },
      'facebook_request' => { button_class: 'fb_request_btn', button_text: 'Send request to friends' },
      'facebook_recommendation' => { button_class: 'fb_recommend_btn', button_text: 'Send to friends' },
      'facebook_autofill_request' => { button_class: 'fb_autofill_request_btn', button_text: 'Send request to friends' }
    }
    button_hash[facebook_sharing_option] || button_hash['facebook_popup']
  end

  def fb_like(url, ref_hash, classes = nil, is_button_count = false)
    url = ref_hash ? "#{url}?f=#{ref_hash}" : url
    attributes = {href: url, send: false, show_faces: false, action: 'like', width: '270'}
    attributes.merge!({layout: 'button_count', width: '100'}) if is_button_count
    tag "fb:like", {data: attributes, class: classes}, false, true
  end

  def after_share_view
    measure! 'after share view 7', :share, [
       "button_is_most_effective_tool-progress_bar",
       "almost_there_only_one_thing_left_to_do",
       "almost_done_only_one_thing_left_to_do",
       "almost_finished_only_one_thing_left_to_do",
       "almost_there_just_one_thing_left_to_do",
       "almost_there_just_one_last_thing_to_do",
       "almost_there_just_one_more_thing_to_do",
       "almost_there_only_one_thing_left_to_do-top_arrow",
       "almost_there_only_one_thing_left_to_do-bottom_arrow",
       "almost_there_only_one_thing_left_to_do-85",
       "almost_there_only_one_thing_left_to_do-85_top_arrow",
       "almost_there_only_one_thing_left_to_do-85_bottom_arrow",
       "almost_there_only_one_thing_left_to_do_or_share_link"
    ]
  end

  def progress_bar_color
    measure! 'change progress bar brightness above sign box (number goes bright to dull, 0 being brightest) 2', :signature, ["progress_bright", "progress_dull", "progress_dark"]
  end

  def progress_box_aesthetic
    spin! 'change background and border of progress box', :signature, [
      "yellow-unbordered",
      "blue-unbordered",
      "green-unbordered",
      "grey-unbordered",
      "red-unbordered",
      "yellow-bordered",
      "blue-bordered",
      "green-bordered",
      "grey-bordered",
      "red-bordered"
    ]
  end

  def sign_button_color
    measure! 'change button brightness and gradient use for sign button (number goes bright to dull, 0 being brightest, flat indicates no gradient) 2', :signature, [
      "btn-red1",
      "btn-red2",
      "btn-red3",
      "btn-red4_with-gradient",
      "btn-red5",
      "btn-red0_flat",
      "btn-red1_flat",
      "btn-red2_flat",
      "btn-red3_flat",
      "btn-red4_flat",
      "btn-red5_flat",
      "btn-danger"
    ]
  end

  def privacy_policy_position_and_color
    return 'inside_aaa' if browser.mobile?
    spin! 'change privacy policy position relative to sign box and color on petition page', :signature, ["inside_ccc", "inside_aaa", "inside_888", "outside_ccc", "outside_aaa", "outside_888"]
  end

  def progress_option
    spin! 'test different messaging on progress bar', :signature, progress_options_config.keys
  end

  def progress
    progress_options_config[progress_option] || {text: '', classes: ''}
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

  def facebook_request_pick_vs_autofill
    return unless @member.present?
    fb_friend = FacebookFriend.find_by_member_id(@member.id)
    fb_friend.present? ? (spin! 'facebook request pick vs autofill', :referred_member, ['facebook_request', 'facebook_autofill_request']) : 'facebook_request'
  end

  def progress_options_config
    total = number_with_delimiter(@sigcount, delimiter: ",")
    goal  = number_with_delimiter(counter_size(@sigcount), delimiter: ",")
    reach = number_with_delimiter(counter_size(@sigcount)-@sigcount, delimiter: ",")

    signatures = "signature".pluralize(@sigcount)
    supporters = @sigcount == 1 ? "supporter has" : "supporters have"
    goal_supporters = counter_size(@sigcount) == 1 ? "supporter has" : "supporters have"

    {
      'x_signatures_of_y' => {
        text: "#{total} #{signatures}<br>of #{goal}",
        classes: 'highlight_text'
      },
      'x_y_to_next_goal' => {
        text: "#{total} #{signatures}<br>Only #{reach} more to reach our next goal!",
        classes: 'highlight_text break'
      },
      'x_y_to_goal' => {
        text: "#{total} #{signatures}<br>Only #{reach} more to reach our goal!",
        classes: 'highlight_text break'
      },
      'x_y_to_go_of_z' => {
        text: "#{total} #{signatures}<br>Only #{reach} more to reach our goal of #{goal}!",
        classes: 'highlight_text break'
      },
      'x_supporters_y_to_next_goal' => {
        text: "#{total} #{supporters} signed<br>Only #{reach} more to reach our next goal!",
        classes: 'highlight_text break'
      },
      'x_supporters_y_to_goal' => {
        text: "#{total} #{supporters} signed<br>Only #{reach} more to reach our goal!",
        classes: 'highlight_text break'
      },
      'x_supporters_help_us' => {
        text: "#{total} #{supporters} signed<br>Sign now to help us reach our goal of #{goal}!",
        classes: 'highlight_text break'
      },
      'x_of_y_supporters' => {
        text: "#{total} of #{goal} #{goal_supporters} signed",
        classes: ''
      }
    }
  end

end
