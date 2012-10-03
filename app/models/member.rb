class Member < ActiveRecord::Base
  has_many :subscribes
  has_many :unsubscribes
  has_many :sent_emails
  has_many :signatures

  attr_accessible :first_name, :last_name, :email, :referral_code
  attr_accessible :country_code, :state_code

  validates :email, :presence => true, :uniqueness => true
  validates :first_name, :last_name, :presence => true

  after_create :set_referral_code

  def self.random_and_not_recently_contacted
    query = <<-SQL
      SELECT members.id
      FROM members 
      WHERE members.id NOT IN (
        SELECT member_id 
        FROM sent_emails 
        WHERE created_at > now() - interval '1 week'
      ) AND members.id NOT IN (
        SELECT member_id
        FROM signatures
        WHERE created_at > now() - interval '1 week'
        AND created_member = 't'
      )
    SQL

    uncontacted_members = Member.connection.execute(query).to_a
    subscribe_dates = Subscribe.group(:member_id).maximum(:created_at)
    unsubscribe_dates = Unsubscribe.group(:member_id).maximum(:created_at)
    receiver_ids = uncontacted_members.select do |m| 
      active_subscription?(subscribe_dates[m['id'].to_i], unsubscribe_dates[m['id'].to_i])
    end

    return nil if receiver_ids.empty?
    Member.find(receiver_ids.sample['id'])
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

  def last_location
    return '' unless (c = country_code) && (s = state_code)
    c == 'US' ? "us/#{s}" : "non-us/#{c}"  
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

  def set_referral_code
    if respond_to?(:referral_code) && referral_code.blank?
      update_attribute(:referral_code, self.to_hash)
    end
  end
end
