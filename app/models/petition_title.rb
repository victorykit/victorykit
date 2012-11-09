class PetitionTitle < ActiveRecord::Base
  attr_accessible :title, :title_type
  attr_accessible :title, :title_type, :as => :admin
  belongs_to :petition

  module TitleType
    EMAIL = 'email'
    FACEBOOK = 'facebook'
    DEFAULT = 'default'
  end

  @TITLE_TYPE_NAMES = {
    TitleType::EMAIL => "Email Subject",
    TitleType::FACEBOOK => "Facebook Title",
    TitleType::DEFAULT => "Title"}
  @TITLE_TYPES = @TITLE_TYPE_NAMES.keys

  def self.types
    @TITLE_TYPES
  end

  def self.full_name type
    @TITLE_TYPE_NAMES[type]
  end
end
