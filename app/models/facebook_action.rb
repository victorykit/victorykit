class FacebookAction < ActiveRecord::Base
  belongs_to :member
  belongs_to :petition
  attr_accessible :type, :action_id
end
