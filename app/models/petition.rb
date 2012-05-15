class Petition < ActiveRecord::Base
  attr_accessible :description, :title
  attr_accessible :description, :title, :to_send, :as => :admin
  has_many :signatures
  belongs_to :owner, class_name:  "User"
  validates_presence_of :title, :description, :owner_id
  
  def has_edit_permissions(current_user)
    owner.id == current_user.id || current_user.is_admin || current_user.is_super_user
  end
  
  
  
  def self.find_interesting_petitions_for(member)
    Petition.find_all_by_to_send(true) -
      Signature.find_all_by_member_id(member).map{|s| s.petition} - 
      SentEmail.find_all_by_member_id(member).map{|e| e.petition}    
  end
end
