class Unsubscribe < ActiveRecord::Base
  attr_accessible :email, :cause, :member
  belongs_to :member
  belongs_to :sent_email
  validates_presence_of :email
  after_create :membership_clean_up
  after_commit :sync_unsub_to_crm, :on => :create

  scope :between, ->(from, to) { where(:created_at => from..to) }
  scope :not_bounced, -> { where(cause: "unsubscribed") }
  delegate :full_name, to: :member

  def self.unsubscribe_member(member)
    Unsubscribe.create(email: member.email, cause: 'unsubscribed', member: member)
  end

  private

  def membership_clean_up
    member.membership.try(:destroy)
  end

  def sync_unsub_to_crm
    SyncUnsubToCrmWorker.perform_async(member.id)
  end

end
