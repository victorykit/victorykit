class Member < ActiveRecord::Base
  attr_accessible :name, :email
  has_many :subscribes
  has_many :unsubscribes
  validates :email, :presence => true, :uniqueness => true
  validates :name, :presence => true

  def self.random_and_not_recently_contacted
	  uncontacted_members = Member.joins("LEFT JOIN sent_emails ON (members.id = sent_emails.member_id AND sent_emails.created_at > now() - interval '1 week') WHERE sent_emails.member_id is null")
	  target_members = uncontacted_members.select {|m|m.subscribed?}
	  target_members.sample
  end

	def subscribed?
		last_subscribed = subscribes.maximum("created_at")
		last_unsubscribed = unsubscribes.maximum("created_at")

		return true if last_unsubscribed.nil?
		return false if last_subscribed.nil?

		last_subscribed > last_unsubscribed
	end
end
