uri = URI.parse(Victorykit::Application.config.redis[:uri])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
