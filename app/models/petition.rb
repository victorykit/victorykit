class Petition < ActiveRecord::Base
  attr_accessible :description, :title
  has_many :signatures
  belongs_to :owner, class_name:  "User"
  validates_presence_of :title, :description, :owner_id
  
  def has_edit_permissions(current_user)
    owner.id == current_user.id || current_user.is_admin || current_user.is_super_user
  end
  
  def analytics
    PetitionAnalytics.new(self)
  end
end
