class FakeStatsd

  def initialize(*args)
    @data = {}
    @data.default = 0
  end

  def increment(stat, sample_rate=1)
    @data[stat] += 1
  end

  def decrement(stat, sample_rate=1)
    @data[stat] -= 1
  end

  def count(stat, count, sample_rate=1)
    @data[stat] = count
  end

  def gauge(stat, value, sample_rate=1)
    @data[stat] = value
  end

  def timing(stat, ms, sample_rate=1)
    @data[stat] = ms
  end

  def value_of(stat)
    @data[stat]
  end

  def host
    "statsd.example.com"
  end

  def port
    8125
  end

  def time(stat, sample_rate=1)
    start = Time.now
    result = yield
    timing(stat, ((Time.now - start) * 1000).round, sample_rate)
    result
  end

end
