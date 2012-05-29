require "old_password_validator"

class User < ActiveRecord::Base
  attr_accessor :old_password
  validates_presence_of :password
  validates_presence_of :password_confirmation
  validates :old_password, :old_password => true, :presence => true,  :on => :update, :if => :password_digest_changed?
  attr_accessible :email, :password, :old_password, :password_confirmation
  attr_accessible :email,  :is_super_user, :is_admin, :as => :admin
  
  has_secure_password
  validates :email, :presence => true, :uniqueness => true , :email => true
  
  after_validation :remove_password_digest_errors
  
  def remove_password_digest_errors
    errors.delete :password_digest if errors.include? :password
  end
end
