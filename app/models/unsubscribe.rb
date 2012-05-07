class Unsubscribe < ActiveRecord::Base
  attr_accessible :email, :cause
  belongs_to :member
  validates_presence_of :email
end