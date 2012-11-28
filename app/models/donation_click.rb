class DonationClick < ActiveRecord::Base
  belongs_to :petition
  belongs_to :member
  attr_accessible :petition, :member, :referral_code_id, :amount
end
