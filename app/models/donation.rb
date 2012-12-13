class Donation < ActiveRecord::Base
  belongs_to :member
  belongs_to :petition
  belongs_to :referral
  attr_accessible :member, :petition, :referral, :amount
  validates_presence_of :petition, :member, :referral

  def self.confirm_payment(amount, hash)
    donor = Member.find_by_hash(hash)
    donation = Donation.where(:member_id => donor, :amount => nil).last
    donation.update_attributes(:amount => amount)

  end

end
