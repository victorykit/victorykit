class Petition < ActiveRecord::Base
  attr_accessible :description, :title
  has_many :signatures
  belongs_to :owner, class_name:  "User"
  validates_presence_of :title
end
