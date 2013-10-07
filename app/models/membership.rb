class Membership < ActiveRecord::Base
  belongs_to :member
  validates_presence_of :member_id, unique: true

  after_commit :sync_subscription_to_crm, :on => :create

  def sync_subscription_to_crm
    SyncSubscriptionToCrmWorker.perform_async(member_id)
  end
end
