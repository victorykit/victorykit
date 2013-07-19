uri = URI.parse(Settings.redis.uri)
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
Whiplash.redis = REDIS
