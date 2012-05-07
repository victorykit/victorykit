module Admin::PetitionsHelper
  
  def link_to_self_with_param option, option_items, delimiter
    option_items.collect { |k,v| link_to k, url_for(params.merge(option => v))}.join(delimiter).html_safe
  end
  
end
