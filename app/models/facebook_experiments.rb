class FacebookExperiments < SocialMediaExperiments

  def title
    default = @petition.title
    return default if not @member

    options = PetitionTitle.find_all_by_petition_id_and_title_type(@petition.id, title_type)
    choice = do_spin!(test_names[:title], :signature, options.map{|opt| opt.title}) if options.any?
    choice || default
  end

  private

  def title_type
    PetitionTitle::TitleType::FACEBOOK
  end

  def test_names
    { :title => "petition #{@petition.id} #{title_type} title" }
  end

end
