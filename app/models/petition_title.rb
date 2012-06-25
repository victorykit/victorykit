class PetitionTitle < ActiveRecord::Base
  attr_accessible :title, :title_type
  attr_accessible :title, :title_type, :as => :admin

  belongs_to :petition

  def text
    title
  end

  module TitleType
    FACEBOOK = 'facebook'
    TWITTER = 'twitter'
    EMAIL = 'email'
    DEFAULT = 'default'
  end

  TITLE_TYPES = [ TitleType::FACEBOOK, TitleType::TWITTER, TitleType::EMAIL, TitleType::DEFAULT, nil ]

  def tracking_hash
    #todo: SentEmailHasher cuz why?
    is_default? ? nil : SentEmailHasher.generate(id)
  end

  private

  def is_default?
    return TitleType::DEFAULT == title_type
  end

end
