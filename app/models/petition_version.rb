class PetitionVersion < ActiveRecord::Base
  
    belongs_to :petition
    attr_accessible :description, :title, :petition_id
    attr_accessible :description, :title, :petition_id, :as => :admin

  end