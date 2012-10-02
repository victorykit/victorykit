module Admin::PetitionsHelper
  
  def link_to_self_with_param param_name, options, delimiter
    options = Hash[options.zip(options)] if options.is_a? Array
    options.collect do |label, value|
      if params[param_name] == value
        label
      else
        link_to label, url_for(params.merge(param_name => value))
      end
    end.join(delimiter).html_safe
  end
  
end
