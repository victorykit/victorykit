class FacebookExperiments < SocialMediaExperiments

  def title
    default = @petition.title
    return default if not @member
    spin!(test_names[:title], :signature, title_options.map{|opt| opt.title}, default)
  end

  def image
    defaults = Rails.configuration.social_media[:facebook][:images]
    return defaults.first if not @member

    petition_images = @petition.petition_images.map { |opt| opt.url }
    images_to_use = petition_images.any? ? petition_images : defaults
    spin!(test_names[:image], :signature, images_to_use)
  end

  private

  def title_options
    PetitionTitle.find_all_by_petition_id_and_title_type(@petition.id, title_type)
  end

  def title_type
    PetitionTitle::TitleType::FACEBOOK
  end

  def test_names
    { :title => "petition #{@petition.id} #{title_type} title",
      :image => @petition.petition_images.any? ? "petition #{@petition.id} #{title_type} image" : "default facebook image" }
  end

end
