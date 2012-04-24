module PetitionsHelper
  def petition_to_open_graph(petition)
    { 
      'og:title' => petition.title, 
      'og:type' => 'cause', 
      'og:description' => petition.description,
      'og:url' => petition_url(petition),
      'og:image' => URI.join(root_url, image_path('petition-fb.png')),
      'og:site_name' => 'Victory Kit'
    }
  end
end
