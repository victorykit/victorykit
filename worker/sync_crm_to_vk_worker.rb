class SyncCrmToVkWorker

  def self.run

    t1 = Time.now

    if CrmState[:syncing]
      CrmState[:sync_locked_retries] = (CrmState[:sync_locked_retries] ? CrmState[:sync_locked_retries].to_i + 1 : 1)
      Rails.logger.warn("SyncCrmToVkWorker: Skipping CRM sync: retries: #{CrmState[:sync_locked_retries]}  locked: #{CrmState[:syncing]}  now: #{Time.now}")
      return
    end

    begin
      CrmState[:syncing] = Time.now

      # members
      last_id = CrmState[:last_member_id]
      while true do
        CrmState[:last_member_id] = CRM.sync_new_crm_members(AppSettings['crm.default_list'], CrmState[:last_member_id])
        break if last_id.to_i == CrmState[:last_member_id].to_i
      end

      # subscription events (subs, unsubs)
      last_id = CrmState[:last_sub_event_id]
      while true do
        CrmState[:last_sub_event_id] = CRM.sync_crm_subscription_events(AppSettings['crm.default_list'], CrmState[:last_sub_event_id])
        break if last_id.to_i == CrmState[:last_sub_event_id].to_i
      end

    rescue => error
      # Airbrake.notify(error)
      Rails.logger.error("SyncCrmToVkWorker: #{error} #{error.backtrace.join("\n")}")

    ensure
      CrmState[:syncing] = nil
      CrmState[:sync_locked_retries] = nil
    end

    Rails.logger.warn("SyncCrmToVkWorker: done: start= #{t1}  dur=#{Time.now - t1}")
  end

end

SyncCrmToVkWorker.run
