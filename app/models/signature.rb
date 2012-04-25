class Signature < ActiveRecord::Base
  attr_accessible :email, :name
  belongs_to :petition
  validates_presence_of :email, :name
end
