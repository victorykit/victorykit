class Member < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email
  has_many :subscribes
  has_many :unsubscribes
  has_many :sent_emails
  has_many :signatures

  validates :email, :presence => true, :uniqueness => true
  validates :first_name, :last_name, :presence => true

  def self.random_and_not_recently_contacted
    uncontacted_members = Member.connection.execute("SELECT members.id FROM members LEFT JOIN sent_emails ON (members.id = sent_emails.member_id AND sent_emails.created_at > now() - interval '1 week') WHERE sent_emails.member_id is null").to_a
    subscribe_dates = Subscribe.group(:member_id).maximum(:created_at)
    unsubscribe_dates = Unsubscribe.group(:member_id).maximum(:created_at)
    subscribed_members = uncontacted_members.select {|m| active_subscription?(subscribe_dates[m['id'].to_i], unsubscribe_dates[m['id'].to_i])}

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

  scope :by_hash, ->(hash) do
    where(:id => MemberHasher.validate(hash))
  end

  def self.find_by_hash(hash)
    self.by_hash(hash).first if hash
  end

  private

  def signature_for(petition)
    signatures.where(petition_id: petition.try(:id)).first
  end

  def self.active_subscription?(subscribe_date, unsubscribe_date)
    return true if unsubscribe_date.nil?
    return false if subscribe_date.nil?
    return subscribe_date > unsubscribe_date
  end

end