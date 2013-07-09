Resque.before_first_fork do
  NewRelic::Agent.manual_start(:dispatcher   => :resque,
                               :sync_startup => true,
                               :start_channel_listener => true)
end

Resque.before_fork do |job|
  NewRelic::Agent.register_report_channel(job.object_id)
end

Resque.after_fork do |job|
  NewRelic::Agent.after_fork(:report_to_channel => job.object_id,
                             :report_instance_busy => false)
end
