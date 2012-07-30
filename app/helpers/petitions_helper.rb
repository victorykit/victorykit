module PetitionsHelper
  
  def social_media_config
    Rails.configuration.social_media
  end

  def find_member_by_id_hash(hash)
    member_id = MemberHasher.validate(hash)
    member = Member.find member_id unless not member_id
  end

  def petition_to_open_graph(petition, member=nil)
    { 
      'og:title' => petition.experiments.facebook(member).title,
      'og:type' => 'watchdognet:petition',
      'og:description' => strip_tags_except_links(petition.facebook_description_for_sharing).squish[0..300],
      'og:image' => petition.experiments.facebook(member).image,
      'og:site_name' => social_media_config[:facebook][:site_name],
      'fb:app_id' => social_media_config[:facebook][:app_id]
    }
  end

  def counter_size(signature_count)
    counters = [5, 10, 50, 100, 250, 500, 750, 1000, 2000, 5000, 7500, 10000, 15000, 20000, 100000, 1000000]
    for i in counters
      if signature_count < i
        return i
      end
    end
  end

  def browser_really_ie?
    browser.ie? && !(browser.user_agent =~ /chromeframe/)
  end

  def choose_form_based_on_browser
    browser_really_ie? ? 'ie_form' : 'form'
  end
  
end
