module PetitionsHelper
  def petition_to_open_graph(petition)
    {'og:title' => petition.title}
  end
end
