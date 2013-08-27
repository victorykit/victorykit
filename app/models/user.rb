class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  attr_accessor :current_password
  attr_accessor :skip_validation

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :current_password, :remember_me
  attr_accessible :is_super_user, :is_admin, :as => :admin

  validates_presence_of :password, :unless => :skip_validation
  validates_presence_of :password_confirmation, :unless => :skip_validation
  validate :check_current_password, :on => :update, :if => :encrypted_password_changed?

  after_validation :remove_encrypted_password_errors
  
  def remove_encrypted_password_errors
    errors.delete :encrypted_password if errors.include? :password
  end

  private

  def check_current_password
    # old_user = User.find(self.id)
    if self.current_password.blank?
      self.errors[:current_password] << " current password can not be blank"
    else
      u = User.find(self.id)
      if ! u.valid_password? current_password
        self.errors[:current_password] << " is not your previous password"
      end
    end
  end


end
