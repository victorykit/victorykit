require 'distribution'
require 'redis'

FAIRNESS_CONSTANT = 3

module Bandit
  def arm_guess(observations, victories)
    if observations == 0
      mean = 0
      stddev = 1
    else
      mean = victories.to_f/observations.to_f
      stddev = Math.sqrt([0, (mean * (1-mean))].max/observations.to_f)
    end
    out = [0, Distribution::Normal.rng(mean, stddev).call].max
    out += FAIRNESS_CONSTANT/(observations.to_f+1)
    return out
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
    sessionid = mysession[:session_id] || request.session_options[:id]
    return "#{sessionid}_#{Random.rand}"
  end
  
  def spin_for_choice(test_name, choice, mysession=nil)
    data = {type: "spin", when: Time.now.to_f, nonce: redis_nonce(mysession), test: test_name, choice: choice}
    Rails.logger.info "WHIPLASH: #{data.to_json}"
    REDIS.incr("whiplash/#{test_name}/#{choice}/spins")
    mysession[test_name] = choice
    return choice
  end

  def measure!(test_name, options=[true, false], mysession=nil)
    mysession ||= session
    if mysession.key?(test_name) && options.include?(mysession[test_name])
      return mysession[test_name]
    end
    
    choice = options.sample
    return spin_for_choice(test_name, choice, mysession)
  end

  def spin!(test_name, goal, options=[true, false], mysession=nil)
    mysession ||= session
    if mysession.key?(test_name) && options.include?(mysession[test_name])
      return mysession[test_name]
    end
    
    REDIS.sadd("whiplash/goals/#{goal}", test_name)
    loptions = {}
    options.each { |o| loptions[o] = [
      REDIS.get("whiplash/#{test_name}/#{o}/spins").to_i,
      REDIS.get("whiplash/#{test_name}/#{o}/wins").to_i
    ] }
    choice = best_guess(loptions)
    return spin_for_choice(test_name, choice, mysession)
  end

  def win_on_option!(test_name, choice, mysession=nil)
    mysession ||= session
    data = {type: "win", when: Time.now.to_f, nonce: redis_nonce(mysession), test: test_name, choice: choice}
    Rails.logger.info "WHIPLASH: #{data.to_json}"
    REDIS.incr("whiplash/#{test_name}/#{choice}/wins")
  end

  def win!(goal, mysession=nil)
    mysession ||= session
    REDIS.smembers("whiplash/goals/#{goal}").each do |t|
      win_on_option!(t, mysession[t], mysession)
    end
  end
end
