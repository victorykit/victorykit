class SyncCrmToVkWorker

  def self.run

    t1 = Time.now

    if CrmState[:syncing]
      CrmState[:sync_locked_retries] = (CrmState[:sync_locked_retries] ? CrmState[:sync_locked_retries].to_i + 1 : 1)
      Rails.logger.warn("SyncCrmToVkWorker: Skipping CRM sync: locked: #{CrmState[:syncing]} now: #{Time.now}")
      return
    end

    begin
      CrmState[:syncing] = Time.now
      CrmState[:last_member_created_at] = CRM.sync_new_crm_members(CrmState[:last_member_created_at], AppSettings['crm.default_list'])
      CrmState[:last_sub_event_ts] = CRM.sync_crm_subscription_events(CrmState[:last_sub_event_ts],   AppSettings['crm.default_list'])

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
