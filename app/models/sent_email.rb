class SentEmail < ActiveRecord::Base
  attr_accessible :email, :member, :petition, :opened_at, :clicked_at, :signature
  belongs_to :petition
  belongs_to :member
  has_many :email_experiments
  has_one :unsubscribe
  belongs_to :signature

  def to_hash
    SentEmailHasher.generate self.id
  end

  scope :by_hash, lambda {|hash| where(:id => SentEmailHasher.validate(hash)) }

  def self.find_by_hash(hash)
    self.by_hash(hash).first
  end

  def already_clicked?
    !self.clicked_at.nil?
  end

  def track_visit!
    self.update_attributes(clicked_at: Time.now) unless already_clicked?
    $statsd.increment "emails_clicked.count"
  end
end
