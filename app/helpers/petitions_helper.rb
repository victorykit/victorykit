module PetitionsHelper

  def open_graph_for(petition, hash)
    member = MemberHasher.member_for(hash)
    { 
      'og:title' => petition.experiments.facebook(member).title,
      'og:type' => 'watchdognet:petition',
      'og:description' => h(petition.facebook_description_for_sharing),
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
    @facebook_sharing_option ||= choose_facebook_sharing_option
  end

  def after_share_view
    @after_share_view_option ||= choose_after_share_view
  end

  private

  def choose_facebook_sharing_option
    return 'facebook_popup' if browser.ie7?
    spin! 'facebook sharing options', :referred_member, ['facebook_like', 'facebook_popup']
  end

  def choose_after_share_view
    return 'modal' if browser.ie? or browser.mobile? or browser.android?
    spin! 'after share view', :share, ['modal', 'hero']
  end

  def really_ie?
    browser.ie? && !(browser.user_agent =~ /chromeframe/)
  end

  def social_media_config
    Rails.configuration.social_media
  end
end
