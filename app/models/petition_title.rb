class PetitionTitle < ActiveRecord::Base
  attr_accessible :title, :title_type
  attr_accessible :title, :title_type, :as => :admin

  belongs_to :petition

  module TitleType
    FACEBOOK = 'facebook'
    TWITTER = 'twitter'
    EMAIL = 'email'
    DEFAULT = 'default'
  end

  TITLE_TYPES = [ TitleType::FACEBOOK, TitleType::TWITTER, TitleType::EMAIL, TitleType::DEFAULT, nil ]

  def text
    title
  end

end
