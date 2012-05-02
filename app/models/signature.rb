class Signature < ActiveRecord::Base
  attr_accessible :email, :name
  belongs_to :petition
  belongs_to :member
  validates_presence_of :email, :name
end
