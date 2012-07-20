def get_db_data
  #@@ get this fron the hottest_controller
end

def restore_scheduled_email_nps
  get_db_data.each { |eid, ov| 
    REDIS.set("whiplash/email_scheduler_nps/#{eid}/spins", ov[0])
    REDIS.set("whiplash/email_scheduler_nps/#{eid}/wins", ov[1])
  }
end
