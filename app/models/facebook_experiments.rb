class FacebookExperiments < SocialMediaExperiments

  def title
    default = @petition.title
    return default if not @member
    spin_or_default!(test_names[:title], :signature, title_options.map{|opt| opt.title}, default)
  end

  def image
    default = Rails.configuration.social_media[:facebook][:image]
    return default if not @member
    spin_or_default!(test_names[:image], :signature, @petition.petition_images.map{|opt| opt.url}, default)
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
      :image => "petition #{@petition.id} #{title_type} image" }
  end

end
