class FacebookExperiments < SocialMediaExperiments

  def title
    default = @petition.title
    return default if not @member

    title_type = PetitionTitle::TitleType::FACEBOOK
    options = PetitionTitle.find_all_by_petition_id_and_title_type(@petition.id, title_type)
    test_name = "petition #{@petition.id} #{title_type} title"
    choice = do_spin!(test_name, :signature, options.map{|opt| opt.title}) if options.any?
    choice || default
  end

end
