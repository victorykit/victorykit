class DonationClick < ActiveRecord::Base
  attr_accessible :petition, :member, :referral_code_id
  belongs_to :petition
  belongs_to :member
end
