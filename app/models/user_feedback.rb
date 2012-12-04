class UserFeedback < ActiveRecord::Base
  attr_accessible :name, :email, :message
  validates_presence_of :message
end
