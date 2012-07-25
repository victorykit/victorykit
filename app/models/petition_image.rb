class PetitionImage < ActiveRecord::Base
  attr_accessible :url
  attr_accessible :url, :as => :admin
  belongs_to :petition
end
