class Donation < ActiveRecord::Base
  belongs_to :member
  belongs_to :petition
  belongs_to :referral
  attr_accessible :member, :petition, :referral, :amount
  validates_presence_of :petition, :member, :referral

  def self.confirm_payment(amount, hash)
    Rails.logger.info(">>> CONFIRM PAYMENT [#{amount}, #{hash}]")
    donator = Member.find_by_hash(hash).first
    Rails.logger.info(">>> DONATOR: #{ donator }")
    donation = Donation.where(:member_id => donator, :amount => nil).last
    Rails.logger.info(">>> DONATION: #{ donation }")
    donation.update_attributes(:amount => amount)
  end

end
