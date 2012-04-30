module Admin::PetitionsHelper
    
  def petition_analytics(results, petition)
    hits = results.find { |k,v| k == petition_path(petition) }[1].pageviews.to_i    
    signatures = petition.signatures.count
    #todo
    new_members = -1

    {
      :hits => hits,
      :signatures => signatures,
      :conversion => (signatures.to_f / hits.to_f).round(1),
      :new_members => new_members,
      :virality => (new_members.to_f / signatures.to_f).round(1)
    }
  end
  
end