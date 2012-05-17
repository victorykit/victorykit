require 'distribution'
require 'redis'

FAIRNESS_CONSTANT = 3

class Float
  def to_1if0
    self.zero? ? 1 : self
  end
end

module Bandit
  def arm_guess(observations, victories)
    mean = victories.to_f/observations.to_f.to_1if0
    stddev = victories * ((1-mean)**2)
    stddev += [0, (observations - victories)].max * ((0-mean)**2)
    stddev = Math.sqrt(stddev * 1.0/((observations.to_f-1).to_1if0))
    stddev = stddev.to_1if0/Math.sqrt(observations.to_f.to_1if0)
    out = [0, Distribution::Normal.rng(mean, stddev).call].max
    return out + (FAIRNESS_CONSTANT * (1.0/observations.to_f.to_1if0))
  end

  def best_guess(options)
    guesses = {}
    options.each { |o, v| guesses[o] = arm_guess(v[0], v[1]) }
    best = options.keys.select { |o| guesses[o] == guesses.values.max }
    return best.sample
  end

  def redis_nonce(mysession)
    # force creation of a session_id
    mysession[:tmp] = 1
    mysession.delete(:tmp)
    return "#{mysession[:session_id]}_#{Random.rand}"
  end  

  def measure!(test_name, options=[true, false], mysession=nil)
    choice = options.sample
    REDIS.zadd("whiplash/#{test_name}/#{choice}/spin", Time.now.to_f, redis_nonce(mysession))
    mysession[test_name] = choice
    return choice
  end

  def spin!(test_name, goal, options=[true, false], mysession=nil)
    mysession ||= session
    if mysession.key?(test_name) && options.include?(mysession[test_name])
      return mysession[test_name]
    end
    
    REDIS.sadd("whiplash/goals/#{goal}", test_name)
    loptions = {}
    options.each { |o| loptions[o] = [
      REDIS.zcard("whiplash/#{test_name}/#{o}/spin"),
      REDIS.zcard("whiplash/#{test_name}/#{o}/win")
    ] }
    choice = best_guess(loptions)
    REDIS.zadd("whiplash/#{test_name}/#{choice}/spin", Time.now.to_f, redis_nonce(mysession))
    mysession[test_name] = choice
    return choice
  end

  def win_on_option!(test_name, choice, mysession=nil)
    REDIS.zadd("whiplash/#{test_name}/#{choice}/win", Time.now.to_f, redis_nonce(mysession))
  end

  def win!(goal, mysession=nil)
    mysession ||= session
    REDIS.smembers("whiplash/goals/#{goal}").each do |t|
      win_on_option!(t, mysession[t], mysession)
    end
  end
end
