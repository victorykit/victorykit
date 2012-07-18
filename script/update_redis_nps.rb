def restore_scheduled_email_nps
  options = Petition.find_all_by_to_send(true).map { |x| x.id }
  redis_data = data_for_options("email_scheduler_nps", options)        

  sent_data = SentEmail.group(:petition_id).count
  new_data = Signature.where(created_member: true).group(:petition_id).count
  sent_data.default, new_data.default = 0, 0
  db_data = Hash[redis_data.keys.collect { |k| [k, [sent_data[k], new_data[k]]]}]

  db_data.each { |eid, ov| 
    REDIS.set("whiplash/email_scheduler_nps/#{eid}/spins", ov[0])
    REDIS.set("whiplash/email_scheduler_nps/#{eid}/wins", ov[1])
  }
end

def wip_nps_chart(db_data)
  # get db_data from above
  
  whiplash_choices = Hash.new(0)
  (1..1000).each {
    whiplash_choices[best_guess(db_data)] += 1
  }
  
  whiplash_choices.sort { |a,b| b[1] <=> a[1] } .each { |n, c|
    puts "#{c/10.0}%\t#{n}\t#{db_data[n]}  \t#{db_data[n][1]/db_data[n][0].to_f}"
  }.nil?
end
