class PetitionTitle < ActiveRecord::Base
  attr_accessible :title, :title_type
  belongs_to :petition

  module TitleType
    FACEBOOK = 'facebook'
    TWITTER = 'twitter'
    EMAIL = 'email'
  end

  TITLE_TYPES = [ TitleType::FACEBOOK, TitleType::TWITTER, TitleType::EMAIL, nil ]

end
