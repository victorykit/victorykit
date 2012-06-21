class Member < ActiveRecord::Base
  attr_accessible :name, :email
  has_many :subscribes
  has_many :unsubscribes
  has_many :sent_emails

  validates :email, :presence => true, :uniqueness => true
  validates :name, :presence => true

  def self.random_and_not_recently_contacted
	  uncontacted_members = Member.joins("LEFT JOIN sent_emails ON (members.id = sent_emails.member_id AND sent_emails.created_at > now() - interval '1 week') WHERE sent_emails.member_id is null")
	  subscribe_dates = Subscribe.group(:member_id).maximum(:created_at)
	  unsubscribe_dates = Unsubscribe.group(:member_id).maximum(:created_at)
    subscribers = uncontacted_members.select {|m| active_subscription?(subscribe_dates[m.id], unsubscribe_dates[m.id])}
	  subscribers.sample
  end

  def self.active_subscription?(subscribe_date, unsubscribe_date)
 		return true if unsubscribe_date.nil?
 		return false if subscribe_date.nil?
 		return subscribe_date > unsubscribe_date
 	end
end