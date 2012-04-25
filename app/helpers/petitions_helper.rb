module PetitionsHelper
  
  def social_media_config
    Rails.configuration.social_media
  end
  
  def petition_to_open_graph(petition)
    { 
      'og:title' => petition.title, 
      'og:type' => 'cause', 
      'og:description' => petition.description,
      'og:url' => petition_url(petition),
      'og:image' => URI.join(root_url, 'assets', 'petition-fb.png'),
      'og:site_name' => social_media_config[:facebook][:site_name],
      'fb:app_id' => social_media_config[:facebook][:app_id]
    }
  end  
end
