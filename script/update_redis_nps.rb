def get_db_data
  #@@ get this fron the hottest_controller
end

def compare
  db_data.each do |eid, ov| 
    if ov != redis_data[eid]
      puts eid
    end
  end
end


def restore_scheduled_email_nps
  get_db_data.each { |eid, ov| 
    REDIS.set("whiplash/email_scheduler_nps/#{eid}/spins", ov[0])
    REDIS.set("whiplash/email_scheduler_nps/#{eid}/wins", ov[1]-ov[2])
  }
end
