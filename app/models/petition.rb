class Petition < ActiveRecord::Base
  attr_accessible :description, :title
  has_many :signatures
  belongs_to :user
  validates_presence_of :title
end
