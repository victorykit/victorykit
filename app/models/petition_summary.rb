class PetitionSummary < ActiveRecord::Base
  attr_accessible :short_summary
  attr_accessible :short_summary, :as => :admin
  belongs_to :petition
end
