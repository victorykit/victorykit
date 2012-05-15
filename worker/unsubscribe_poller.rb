class UnsubscribePoller
  
  def self.unsubscribe_users
    LastUpdatedUnsubscribe.transaction do
      unsubscribe_poller = LastUpdatedUnsubscribe.find_by_id(1, :lock => true)
      if !unsubscribe_poller.nil? && !unsubscribe_poller.is_locked?
        begin
          lock_unsubscribe_poller(unsubscribe_poller, true)
          emails_to_unsubscribe = get_members_to_unsubscribe(unsubscribe_poller.updated_at)
          unsubscribe_members(emails_to_unsubscribe)
        rescue => error
          puts "Error in retrieving and unsubscribing users #{error} #{error.backtrace.join}"
        ensure
          lock_unsubscribe_poller(unsubscribe_poller, false)
        end
      end
    end
  end
  
  def self.get_members_to_unsubscribe(last_updated)
    #sql = ActiveRecord::Base.establish_connection("mysql://dp_aaron@demandprogress.client-db.actionkit.com/ak_dprogress")
    #emails, created_at = sql.execute("select email, core_action.created_at from core_action join core_unsubscribeaction on (core_action.id = core_unsubscribeaction.action_ptr_id) join core_user on (core_user.id = core_action.user_id) where core_action.created_at > '" + last_updated.to_s + "' order by created_at desc")
    emails = []
  end
  
  def self.unsubscribe_members(emails)
    emails.each do |email|
      member = Member.find_by_email(email)
      if !member.nil?
        unsubscribe = Unsubscribe.new(email: email, cause: "unsubscribed", member: member)
        unsubscribe.save!
      end
    end
  end
  
  def self.lock_unsubscribe_poller(unsubscribe_poller, lock)
    unsubscribe_poller.is_locked = lock
    unsubscribe_poller.save!
  end
end

UnsubscribePoller.unsubscribe_users