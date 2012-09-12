class Member < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email
  has_many :subscribes
  has_many :unsubscribes
  has_many :sent_emails
  has_many :signatures

  validates :email, :presence => true, :uniqueness => true
  validates :first_name, :last_name, :presence => true

  def self.random_and_not_recently_contacted
    query = "SELECT id FROM members WHERE id NOT IN (SELECT member_id FROM sent_emails WHERE created_at > now() - interval '1 week')"

    uncontacted_members = Member.connection.execute(query).to_a
    subscribe_dates = Subscribe.group(:member_id).maximum(:created_at)
    unsubscribe_dates = Unsubscribe.group(:member_id).maximum(:created_at)
    subscribed_members = uncontacted_members.select do |m| 
      active_subscription?(subscribe_dates[m['id'].to_i], unsubscribe_dates[m['id'].to_i])
    end

    return nil if subscribed_members.empty?
    Member.find(subscribed_members.sample['id'])
  end

  def full_name
    [self.first_name,self.last_name].join " "
  end

  def has_signed?(petition)
    signature_for(petition).present?
  end

  def to_hash
    MemberHasher.generate self.id
  end

  def self.find_by_hash(hash)
    where(:id => MemberHasher.validate(hash)).first
  end

  def latest_subscription
    subscribes.order("created_at DESC").first
  end

  private

  def signature_for(petition)
    signatures.where(petition_id: petition.try(:id)).first
  end

  def self.active_subscription?(subscribe_date, unsubscribe_date)
    subscribe_date.present? && 
    subscribe_date < 1.week.ago && 
    ( unsubscribe_date.nil? || subscribe_date > unsubscribe_date )
  end
end