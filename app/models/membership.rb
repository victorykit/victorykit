class Membership < ActiveRecord::Base
  belongs_to :member
  validates_presence_of :member_id, unique: true

  after_commit :sync_subscription_to_crm, :on => :create

  def sync_subscription_to_crm
    # Kind of kludgey, but want to avoid unneeded work.
    # If membership originates from the CRM then we
    # do not need to tell the CRM about it...
    unless self.member.syncing_from_crm?
      SyncSubscriptionToCrmWorker.perform_async(member_id)
    end
  end
end
