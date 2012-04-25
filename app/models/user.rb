class User < ActiveRecord::Base
  has_secure_password
  validates_uniqueness_of :email
  validates_presence_of :email
  attr_accessible :email, :password, :password_confirmation, :is_super_user
end
