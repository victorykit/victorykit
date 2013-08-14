class Member < ActiveRecord::Base
  has_many :subscribes
  has_many :unsubscribes
  has_many :sent_emails
  has_many :signatures
  has_many :referrals, autosave: true
  has_one  :membership, dependent: :destroy

  attr_accessible :first_name, :last_name, :email
  attr_accessible :country_code, :state_code

  validates :email, :presence => true, :uniqueness => true, :email => true
  validates :first_name, :last_name, :presence => true

  scope :lookup, lambda { |email|
    where("LOWER(email) = ?", email.downcase)
  }

  scope :active, -> {
    joins('LEFT JOIN unsubscribes ON unsubscribes.member_id = members.id').
    where('unsubscribes.id IS NULL')
  }

  def self.random_and_not_recently_contacted(n)
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
      ) AND members.id NOT IN (
        SELECT DISTINCT member_id FROM unsubscribes
      ) ORDER BY random() LIMIT #{n}
    SQL

    receiver_ids = Member.connection.execute(query).to_a.map {|m| m['id'].to_i}

    Member.where(id: receiver_ids).all
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

  def last_location
    return '' unless (c = country_code) && (s = state_code)
    c == 'US' ? "us/#{s}" : "non-us/#{c}"
  end

  def signature_for(petition)
    signatures.where(petition_id: petition.try(:id)).first
  end

  def previous_petition_ids
    if REDIS.exists previous_petition_ids_key
      REDIS.smembers(previous_petition_ids_key).map &:to_i
    else
      signed = Signature.where(member_id: id).pluck(:petition_id)
      sent   = ScheduledEmail.where(member_id: id).pluck(:petition_id)
      ( signed + sent ).tap do |ids|
        REDIS.sadd previous_petition_ids_key, ids if ids.any?
      end
    end
  end

  def add_petition_id(id)
    REDIS.sadd previous_petition_ids_key, id
  end

  def touch_last_signed_at!
    lazy_membership.touch(:last_signed_at)
  end

  def touch_last_emailed_at!
    lazy_membership.touch(:last_emailed_at)
  end

  private

  def lazy_membership
    self.membership || self.build_membership
  end

  def previous_petition_ids_key
    "member/#{id}/previous_petition_ids"
  end

  def self.active_subscription?(subscribe_date, unsubscribe_date)
    return true if unsubscribe_date.nil?
    return false if subscribe_date.nil?
    return subscribe_date > unsubscribe_date
  end
end
