class SocialMediaTrial < ActiveRecord::Base
  attr_accessible :choice, :goal, :key, :member_id, :petition_id
  belongs_to :member
  belongs_to :petition
end