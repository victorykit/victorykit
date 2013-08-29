class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :is_super_user, :is_admin, :as => :admin

  after_validation :remove_encrypted_password_errors
  
  def remove_encrypted_password_errors
    errors.delete :encrypted_password if errors.include? :password
  end

end
