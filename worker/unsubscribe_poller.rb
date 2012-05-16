class UnsubscribePoller
  
  def self.unsubscribe_users
    LastUpdatedUnsubscribe.transaction do

      update_token = LastUpdatedUnsubscribe.find_by_id(1, :lock => true)
      update_token = bootstrap(update_token)
        
      if update_token.is_locked
        Rails.logger.info "Skipping update of unsubscribe users: LastUpdateUnsubscribe is locked."
        return
      end
      
      begin
        lock_update_token(update_token, true)
        unsubscribe_requests = import_unsubscribe_requests(update_token.updated_at)
        unsubscribe_members(unsubscribe_requests)
        update_token.updated_at = unsubscribe_requests.max { |x,y| x.created_at <=> y.created_at }.created_at
      rescue => error
        puts "Error in retrieving and unsubscribing users #{error} #{error.backtrace.join}"
      ensure
        lock_update_token(update_token, false)
      end
    end
  end

  def self.bootstrap(update_token)
    update_token.nil? ? LastUpdatedUnsubscribe.new(id: 1, updated_at: Time.at(0)) : update_token
  end
      
  def self.import_unsubscribe_requests(last_updated)
    CoreAction.fetch_unsubscribers_since(last_updated)
  end
  
  def self.unsubscribe_members(unsubscribe_requests)
    unsubscribe_requests.each do |request|
      member = Member.find_by_email(request.email)
      unsubscribe_member(member) unless member.nil?
    end
  end
  
  def self.unsubscribe_member(member)
    Unsubscribe.create(email: member.email, cause: "unsubscribed", member: member)
  end
  
  def self.lock_update_token(update_token, lock)
    update_token.is_locked = lock
    update_token.save!
  end
end

UnsubscribePoller.unsubscribe_users