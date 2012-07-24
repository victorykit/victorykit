module PetitionsHelper
  
  def social_media_config
    Rails.configuration.social_media
  end
  
  def petition_to_open_graph(petition)
    member_id = MemberHasher.validate(params[:m])
    member = Member.find member_id unless not member_id
    { 
      'og:title' => petition.experiments.facebook(member).title,
      'og:type' => 'watchdognet:petition',
      'og:description' => strip_tags_except_links(petition.description).squish[0..300],
      'og:image' => social_media_config[:facebook][:image],
      'og:site_name' => social_media_config[:facebook][:site_name],
      'fb:app_id' => social_media_config[:facebook][:app_id]
    }
  end

  def counter_size(petition_count)
    counters = [5, 10, 50, 100, 250, 500, 750, 1000, 2000, 5000, 7500, 10000, 15000, 20000, 100000, 1000000]
    for i in counters
      if petition_count < i
        return i
      end
    end
  end
end
