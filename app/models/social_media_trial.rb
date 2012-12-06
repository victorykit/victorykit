class SocialMediaTrial < ActiveRecord::Base
  belongs_to :member
  belongs_to :petition
  belongs_to :referral
  attr_accessible :choice, :goal, :key, :member_id, :petition_id, :referral
end
