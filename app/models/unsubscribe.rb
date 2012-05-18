class Unsubscribe < ActiveRecord::Base
  attr_accessible :email, :cause, :member
  belongs_to :member
  belongs_to :sent_email
  validates_presence_of :email
end