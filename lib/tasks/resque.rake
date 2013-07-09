require 'resque/tasks'

task 'resque:setup' => :environment do
  ENV['QUEUE'] = '*'

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
    ActiveRecord::Base.establish_connection
  end

  if ENV['AIRBRAKE_API_KEY'] 
    require 'resque/failure/multiple'
    require 'resque/failure/airbrake'
    require 'resque/failure/redis'

    Resque::Failure::Airbrake.configure do |config|
      config.api_key = ENV['AIRBRAKE_API_KEY']
      config.secure = true 
    end

    Resque::Failure::Multiple.classes = [
      Resque::Failure::Redis, 
      Resque::Failure::Airbrake
    ]

    Resque::Failure.backend = Resque::Failure::Multiple
  end
end
