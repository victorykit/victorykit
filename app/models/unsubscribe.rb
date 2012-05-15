class Unsubscribe < ActiveRecord::Base
  attr_accessible :email, :cause, :member
  belongs_to :member
  validates_presence_of :email
end