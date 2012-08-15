require 'simple-random'
require 'redis'

module Whiplash

  FAIRNESS_CONSTANT7 = FC7 = 2

  # Given a test name and a list of options, returns the one you should expose to users.
  def measure!(test_name, options=[true, false])
    if whiplash_session.key?(test_name) && options.include?(whiplash_session[test_name])
      return whiplash_session[test_name]
    end
    
    choice = options.sample
    return spin_for_choice(test_name, choice)
  end

  # Given a test name, goal, and list of options, returns the one you should expose to users.
  def spin!(test_name, goal, options=[true, false])
    return options.first if options.count == 1

    #manual_whiplash_mode allows to set new options using /whiplash_sessions page
    if whiplash_session.key?(test_name) && (options.include?(whiplash_session[test_name]) || whiplash_session.key?("manual_whiplash_mode"))
      return whiplash_session[test_name]
    end
    
    REDIS.sadd("whiplash/goals/#{goal}", test_name)
    choice = best_guess(data_for_options(test_name, options))
    return spin_for_choice(test_name, choice)
  end

  # Given a test name and choice, record a win for that choice.
  def win_on_option!(test_name, choice)
    data = {type: "win", when: Time.now.to_f, nonce: redis_nonce, test: test_name, choice: choice}
    Rails.logger.info "WHIPLASH: #{data.to_json}"
    REDIS.incr("whiplash/#{test_name}/#{choice}/wins")
  end

  # Given a test name and choice, record a loss for that choice.
  def lose_on_option!(test_name, choice)
    data = {type: "lose", when: Time.now.to_f, nonce: redis_nonce, test: test_name, choice: choice}
    Rails.logger.info "WHIPLASH: #{data.to_json}"
    REDIS.decr("whiplash/#{test_name}/#{choice}/wins")
  end

  # Given a goal, record a win for every test with that goal, deriving the choice from the session.
  def win!(goal)
    REDIS.smembers("whiplash/goals/#{goal}").each do |test_name|
      choice = whiplash_session[test_name]
      win_on_option!(test_name, choice)
    end
  end

  def best_guess(options)
    guesses = {}
    options.each { |o, v| guesses[o] = arm_guess(v[0], v[1]) }
    gmax = guesses.values.max
    best = options.keys.select { |o| guesses[o] ==  gmax }
    return best.sample
  end

  protected

  def arm_guess(observations, victories)
    a = [victories, 0].max
    b = [observations-victories, 0].max
    s = SimpleRandom.new; s.set_seed; s.beta(a+FC7, b+FC7)
  end
  
  
  def data_for_options(test_name, options)
    loptions = {}
    options.each { |o| loptions[o] = [
      REDIS.get("whiplash/#{test_name}/#{o}/spins").to_i,
      REDIS.get("whiplash/#{test_name}/#{o}/wins").to_i
    ] }
    loptions
  end

  def redis_nonce
    "#{self.whiplash_session_id}_#{Random.rand}"
  end
  
  def spin_for_choice(test_name, choice)
    data = {type: "spin", when: Time.now.to_f, nonce: redis_nonce, test: test_name, choice: choice}
    Rails.logger.info "WHIPLASH: #{data.to_json}"
    REDIS.incr("whiplash/#{test_name}/#{choice}/spins")
    whiplash_session[test_name] = choice
    return choice
  end

  def whiplash_session
    ( self.respond_to?(:session) && touch_session ) || {}
  end

  def whiplash_session_id
    whiplash_session[:session_id] || request.session_options[:id]
  end

  # force creation of a session_id
  # TODO there are private Rails methods you can call to achieve this - consider preferring them
  def touch_session
    self.session[:tmp] = 1
    self.session.delete(:tmp)
    self.session
  end
  
end
