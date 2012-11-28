require 'resque/tasks'
require 'resque/failure/multiple'
require 'resque/failure/airbrake'
require 'resque/failure/redis'

task 'resque:setup' => :environment do
  ENV['QUEUE'] = '*'

  Resque.after_fork do |job|
    ActiveRecord::Base.establish_connection
  end

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
