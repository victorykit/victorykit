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

  def self.find_by_hash(hash)
    self.where(:id => SentEmailHasher.validate(hash)).first
  end
end
