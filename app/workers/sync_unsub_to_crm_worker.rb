class SyncUnsubToCrmWorker
  include Sidekiq::Worker

  def perform(member_id)
    member = Member.find_by_id(member_id)
    CRM.unsub_member(member) if member
  end

end
