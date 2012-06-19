class PetitionTitle < ActiveRecord::Base
  attr_accessible :title, :title_type
  belongs_to :petition

  module TitleType
    FACEBOOK = 'facebook'
    TWITTER = 'twitter'
    EMAIL = 'email'
  end

  REFERENCE_TYPES = [ TitleType::FACEBOOK, TitleType::TWITTER, TitleType::EMAIL, nil ]

end
