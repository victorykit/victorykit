class SyncSubscriptionToCrmWorker
  include Sidekiq::Worker

  def perform(member_id)
    member = Member.find_by_id(member_id)
    CRM.subscribe_member(member) if member
  end

end
