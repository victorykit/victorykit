module PetitionsHelper
  
  def social_media_config
    Rails.configuration.social_media
  end
  
  def petition_to_open_graph(petition)
    { 
      'og:title' => facebook_title(petition), 
      'og:type' => 'cause', 
      'og:description' => strip_tags_except_links(petition.description).squish[0..300],
      'og:url' => petition_url(petition),
      'og:image' => social_media_config[:facebook][:image],
      'og:site_name' => social_media_config[:facebook][:site_name],
      'fb:app_id' => social_media_config[:facebook][:app_id]
    }
  end
  
  def facebook_title(petition)
    facebook_titles = petition.petition_titles.find_all_by_title_type("facebook").map { |fb_title| fb_title.title }
    facebook_title = spin! "petition #{petition.id} facebook title", :petition, facebook_titles unless not facebook_titles
    facebook_title || petition.title
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
