class DonationClick < ActiveRecord::Base
  belongs_to :member
  belongs_to :petition
  belongs_to :referral_code
  attr_accessible :member, :petition, :referral_code, :amount
  validates_presence_of :petition, :member, :referral_code
end
