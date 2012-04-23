class Petition < ActiveRecord::Base
  attr_accessible :description, :title
  has_many :signatures
end
