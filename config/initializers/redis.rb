uri = URI.parse(Settings.redis.uri)
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
Resque.redis = REDIS
Whiplash.redis = REDIS
