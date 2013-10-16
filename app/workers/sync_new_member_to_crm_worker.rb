class SyncNewMemberToCrmWorker
  include Sidekiq::Worker

  def perform(member_id)
    vk_member = Member.find_by_id(member_id)
    CRM.create_member(vk_member) if vk_member
  end

end
