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
        unsubscribe_requests = ActionKitUnsubscribeGateway.fetch_unsubscribers_since(update_token.updated_at)
        unsubscribe_requests.each {|r| r.unsubscribe_member}
        latest_member_created = unsubscribe_requests.max { |x,y| x.created_at <=> y.created_at }
        update_token.updated_at = latest_member_created.nil? ? update_token.updated_at : latest_member_created.created_at
      rescue => error
        Airbrake.notify(error)
        Rails.logger.error "Error in retrieving and unsubscribing users #{error} #{error.backtrace.join}"
      ensure
        lock_update_token(update_token, false)
      end
    end
  end

  private

  def self.bootstrap(update_token)
    update_token.nil? ? LastUpdatedUnsubscribe.new(id: 1, updated_at: Time.at(0)) : update_token
  end

  def self.lock_update_token(update_token, lock)
    update_token.is_locked = lock
    update_token.save!
  end

end

UnsubscribePoller.unsubscribe_users
