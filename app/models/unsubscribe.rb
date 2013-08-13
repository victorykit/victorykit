class Unsubscribe < ActiveRecord::Base
  attr_accessible :email, :cause, :member
  belongs_to :member
  belongs_to :sent_email
  validates_presence_of :email

  scope :between, ->(from, to) { where(:created_at => from..to) }
  delegate :full_name, to: :member

  def self.unsubscribe_member(member)
    member.membership.try(:destroy)
    Unsubscribe.create(email: member.email, cause: 'unsubscribed', member: member)
  end
end
