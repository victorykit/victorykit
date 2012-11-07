class PetitionDescription < ActiveRecord::Base
  attr_accessible :facebook_description
  attr_accessible :facebook_description, :as => :admin
  belongs_to :petition
end
