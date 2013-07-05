class Member < ActiveRecord::Base
  has_many :subscribes
  has_many :unsubscribes
  has_many :sent_emails
  has_many :signatures
  has_many :referrals, autosave: true

  attr_accessible :first_name, :last_name, :email
  attr_accessible :country_code, :state_code

  validates :email, :presence => true, :uniqueness => true
  validates :first_name, :last_name, :presence => true

  scope :active, -> { where('id not in (select member_id from unsubscribes)') }

  CSV_COLUMNS = [:first_name, :last_name, :email, :state_code]

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
      ) ORDER BY random() LIMIT #{n}
    SQL

    uncontacted_members = Member.connection.execute(query).to_a
    subscribe_dates = Subscribe.group(:member_id).maximum(:created_at)
    unsubscribe_dates = Unsubscribe.group(:member_id).maximum(:created_at)
    receiver_ids = uncontacted_members.select do |m| 
      active_subscription?(subscribe_dates[m['id'].to_i], unsubscribe_dates[m['id'].to_i])
    end

    return [] if receiver_ids.empty?
    Member.find_all_by_id(receiver_ids.sample(n).collect{|x| x['id']})
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

  def signature_for(petition)
    signatures.where(petition_id: petition.try(:id)).first
  end

  def csv_header
    CSV_COLUMNS.map { |c| c.to_s.titleize }
  end

  def csv_values
    CSV_COLUMNS.map { |c| self.send(c) }
  end


  def previous_petition_ids
    if REDIS.exists previous_petition_ids_key
      previous_petition_ids = REDIS.smembers previous_petition_ids_key
    else
      signed = Signature.where(member_id: id).select(:petition_id).map(&:petition_id)
      sent = ScheduledEmail.where(member_id: id).select(:petition_id).map(&:petition_id)
      previous_petition_ids = signed + sent
      REDIS.sadd previous_petition_ids_key, previous_petition_ids if previous_petition_ids.any?
    end
    previous_petition_ids
  end

  def add_petition_id(id)
    REDIS.sadd previous_petition_ids_key, id
  end

  private

  def previous_petition_ids_key
    "member/#{id}/previous_petition_ids"
  end

  def self.active_subscription?(subscribe_date, unsubscribe_date)
    return true if unsubscribe_date.nil?
    return false if subscribe_date.nil?
    return subscribe_date > unsubscribe_date
  end
end
