class Unsubscribe < ActiveRecord::Base
  attr_accessible :email, :cause, :member
  belongs_to :member
  belongs_to :sent_email
  validates_presence_of :email
  after_create :destroy_membership

  scope :between, ->(from, to) { where(:created_at => from..to) }
  scope :not_bounced, -> { where(cause: "unsubscribed") }
  delegate :full_name, to: :member

  def self.unsubscribe_member(member)
    Unsubscribe.create(email: member.email, cause: 'unsubscribed', member: member)
  end

  private

  def destroy_membership
    member.membership.try(:destroy)
  end
end
