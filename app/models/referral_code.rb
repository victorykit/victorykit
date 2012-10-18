class ReferralCode < ActiveRecord::Base
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

      spin! test_names[:image], :signature, images_to_use
    end
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
      :image => petition.petition_images.any? ? "petition #{petition.id} #{title_type} image" : "default facebook image 2" }
  end

end