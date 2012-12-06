class Referral < ActiveRecord::Base
  include Whiplash
  attr_accessible :code, :member_id, :petition_id, :member, :petition

  belongs_to :member
  belongs_to :petition

  has_many :social_media_trials
  validates :code, uniqueness: true
  validates :petition_id, presence: true

  after_initialize :generate_code

  scope :unused, where(member_id: nil)

  def spin!(*args)
    save if new_record?
    super
  end

  def title
    if member_id.blank? || title_options.empty?
      petition.title
    else
      spin! test_names[:title], :signature, title_options.map(&:title)
    end
  end

  def image
    defaults = Rails.configuration.social_media[:facebook][:images]

    if member_id.blank?
      defaults.first
    else
      petition_images = petition.petition_images.map(&:url)
      images_to_use = petition_images.any? ? petition_images : defaults

      url = spin!(test_names[:image], :signature, images_to_use)
      PetitionImage.find_by_url(url).public_url rescue url
    end
  end

  def prefer_commenters_to_likers
    spin!('prefer_commenters_to_likers', :signature, ['commenters', 'likers']) == 'commenters'
  end

  def facebook_description_for_sharing
    facebook_descriptions = petition.petition_descriptions.map(&:facebook_description)
    description_choice = spin! test_names[:description], :signature, facebook_descriptions if facebook_descriptions.any?
    description_choice.present? ? description_choice : petition.default_description_for_sharing
  end

  def session
    @session ||= ActiveRecordWhiplashSession.new(
      session_id: self.code, 
      scope: self.social_media_trials, 
      test_column: :key, 
      choice_column: :choice
    )
  end

  def reload
    @session = nil
    super
  end

  private

  def generate_code
    if self.code.blank? && self.new_record?
      self.code = SecureRandom.urlsafe_base64(8)
    end
  end

  def title_options
    PetitionTitle.where(petition_id: self.petition_id, title_type: title_type).all
  end

  def title_type
    PetitionTitle::TitleType::FACEBOOK
  end

  def test_names
    { :title => "petition #{petition.id} #{title_type} title",
      :image => petition.petition_images.any? ? "petition #{petition.id} #{title_type} image" : "default facebook image 2",
      :description => "petition #{petition.id} #{title_type} description" }
  end

end
