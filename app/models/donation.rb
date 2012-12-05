class Donation < ActiveRecord::Base
  belongs_to :member
  belongs_to :petition
  belongs_to :referral_code
  attr_accessible :member, :petition, :referral_code, :amount
  validates_presence_of :petition, :member, :referral_code

  def self.confirm_payment(amount, email)
    donator = Member.where(:email => email).first
    donation = Donation.where(:member_id => donator, :amount => nil).last
    donation.update_attributes(:amount => amount)
  end

end
