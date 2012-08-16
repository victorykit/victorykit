require 'simple-random'
require 'redis'

FAIRNESS_CONSTANT7 = FC7 = 2

module Whiplash
  def arm_guess(observations, victories)
    a = [victories, 0].max
    b = [observations-victories, 0].max
    s = SimpleRandom.new; s.set_seed; s.beta(a+FC7, b+FC7)
  end
  
  def best_guess(options)
    guesses = {}
    options.each { |o, v| guesses[o] = arm_guess(v[0], v[1]) }
    gmax = guesses.values.max
    best = options.keys.select { |o| guesses[o] ==  gmax }
    return best.sample
  end
  
  def data_for_options(test_name, options)
    loptions = {}
    options.each { |o| loptions[o] = [
      REDIS.get("whiplash/#{test_name}/#{o}/spins").to_i,
      REDIS.get("whiplash/#{test_name}/#{o}/wins").to_i
    ] }
    loptions
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
    return options.first if options.count == 1

    mysession ||= session
    #manual_whiplash_mode allows to set new options using /whiplash_sessions page
    if mysession.key?(test_name) && (options.include?(mysession[test_name]) || mysession.key?("manual_whiplash_mode"))
      return mysession[test_name]
    end
    
    REDIS.sadd("whiplash/goals/#{goal}", test_name)
    choice = best_guess(data_for_options(test_name, options))
    return spin_for_choice(test_name, choice, mysession)
  end

  def win_on_option!(test_name, choice, mysession=nil)
    mysession ||= session
    data = {type: "win", when: Time.now.to_f, nonce: redis_nonce(mysession), test: test_name, choice: choice}
    Rails.logger.info "WHIPLASH: #{data.to_json}"
    REDIS.incr("whiplash/#{test_name}/#{choice}/wins")
  end

  def lose_on_option!(test_name, choice, mysession=nil)
    mysession ||= session
    data = {type: "lose", when: Time.now.to_f, nonce: redis_nonce(mysession), test: test_name, choice: choice}
    Rails.logger.info "WHIPLASH: #{data.to_json}"
    REDIS.decr("whiplash/#{test_name}/#{choice}/wins")
  end

  def win!(goal, mysession=nil)
    mysession ||= session
    REDIS.smembers("whiplash/goals/#{goal}").each do |t|
      win_on_option!(t, mysession[t], mysession)
    end
  end
end
