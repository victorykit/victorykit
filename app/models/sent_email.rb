class SentEmail < ActiveRecord::Base
  attr_accessible :email, :member, :petition
  belongs_to :petition
  belongs_to :member
  has_many :email_experiments
  has_one :unsubscribe
  after_create :update_sent_email_timestamp

  def to_hash
    SentEmailHasher.generate self.id
  end

  scope :by_hash, lambda {|hash| where(:id => SentEmailHasher.validate(hash)) }

  def self.find_by_hash(hash)
    self.by_hash(hash).first
  end

  private

  def update_sent_email_timestamp
    member.touch_last_emailed_at!
  end
end
