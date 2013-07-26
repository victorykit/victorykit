# https://github.com/mperham/sidekiq/wiki/Advanced-Options
# https://github.com/mperham/sidekiq/issues/503
Sidekiq.configure_server do |config|
  database_url = ENV['DATABASE_URL']
  if database_url
    pool_size = ENV['DB_POOL'] || 5
    ENV['DATABASE_URL'] = "#{database_url}?pool=#{pool_size}"
    ActiveRecord::Base.establish_connection
  end
end
