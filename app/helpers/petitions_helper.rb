module PetitionsHelper

  def open_graph_for(petition, hash)
    member = Member.find_by_hash(hash)
    {
      'og:title' => petition.experiments.facebook(member).title,
      'og:type' => 'watchdognet:petition',
      'og:description' => petition.facebook_description_for_sharing.html_safe,
      'og:image' => petition.experiments.facebook(member).image,
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
    winner =  spin! 'facebook sharing options', :referred_member, ['facebook_popup', 'facebook_request', 'facebook_wall']
    (winner == 'facebook_request') ? facebook_request_pick_vs_autofill : winner
  end

  def facebook_button_aesthetic
    spin! 'facebook button aesthetic', :share, ["fb_f_24_share", "fb_f_24_shareonfacebook", "fb_f_share", "fb_f_shareonfacebook", "fb_no_f_share", "fb_no_f_shareonfacebook", "fb_clipped_f_share", "fb_clipped_f_shareonfacebook", "fb_24k_share", "fb_24k_shareonfacebook", "fb_red_share", "fb_red_shareonfacebook"]
  end

  def facebook_button
    button_hash = {
      'facebook_share' => { button_class: 'fb_share', button_text: 'Share on Facebook' },
      'facebook_popup' => { button_class: 'fb_popup_btn', button_text: 'Share on Facebook' },
      'facebook_wall' => { button_class: 'fb_widget_btn', button_text: 'Share with your friends' },
      'facebook_request' => { button_class: 'fb_request_btn', button_text: 'Send request to friends' },
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
    return 'thanks_for_signing' if browser.ie?
    spin! 'after share view 2', :share, [
      "thanks_for_signing",
      "button_is_most_effective_tool",
      "button_is_most_effective_tool_with_thanks",
      "tell_two_friends",
      "tell_two_friends_with_thanks",
      "signatures_stop_signatures_multiply",
      "signatures_stop_signatures_multiply_with_thanks",
      "mandela-time_ripe_to_do_right",
      "mandela-time_ripe_to_do_right-color",
      "teresa-stone_creates_ripples-color",
      "gandhi-shake_the_world",
      "king-do_what_is_right",
      "king-do_what_is_right-color",
      "melanie_1",
      "melanie_2",
      "most_people_will_share_will_you",
      "most_people_will_share_will_you_with_thanks",
      "over_x_shares_and_counting-with_counter",
      "if_facebook_is_slow_try_again_later",
      "tell_two_friends-sandwich-grey",
      "almost_there_one_thing_to_do",
      "almost_there_one_thing_to_do_with_thanks",
      "checklist",
      "demand_progress_facebook_pictures",
      "demand_progress_facebook_pictures_with_thanks",
      "wow_most_shared_petition_ever",
      "hey_youre_not_done_yet",
      "hey_you_youre_not_done_yet",
      "thanks_youre_not_done_yet",
      "name_youre_not_done_yet",
      "kitten_sad",
      "kitten_treat",
      "kitten_gun",
      "puppy_sad",
      "puppy_treat",
      "puppy_gun",
      "ferret_treat"
    ]
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
