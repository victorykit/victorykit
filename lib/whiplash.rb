require 'simple-random'
require 'redis'

module Whiplash
  FAIRNESS_CONSTANT7 = FC7 = 2

  # Given a test name and a list of options, returns the one you should expose to users.
  def measure!(test_name, options=[true, false])
    if whiplash_session.key?(test_name) && options.include?(whiplash_session[test_name])
      return whiplash_session[test_name]
    else
      spin_for_choice! test_name, options.sample
    end
  end

  # Given a test name, goal, and list of options, returns the one you should expose to users.
  def spin!(test_name, goal, choices=[true, false])
    if choices.count == 1
      choices.first
    elsif previously_spun?(test_name, choices) || manually_spun?(test_name)
      whiplash_session[test_name]
    else
      REDIS.sadd("whiplash/goals/#{goal}", test_name)
      spin_for_choice! test_name, choices
    end
  end

  # Given a test name and choice, record a win for that choice.
  def win_on_option!(test_name, choice)
    log test_name, choice, 'win'
    REDIS.incr("whiplash/#{test_name}/#{choice}/wins")
  end

  # Given a test name and choice, record a loss for that choice.
  def lose_on_option!(test_name, choice)
    log test_name, choice, 'lose'
    REDIS.decr("whiplash/#{test_name}/#{choice}/wins")
  end

  # Given a goal, record a win for every test with that goal, deriving the choice from the session.
  def win!(goal)
    all_whiplash_tests(goal).each do |test_name|
      choice = whiplash_session[test_name]
      next if choice.blank?
      win_on_option! test_name, choice
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

  def manual_mode?
    whiplash_session.key?("manual_whiplash_mode")
  end

  def manually_spun?(test_name)
    whiplash_session.key?(test_name) && manual_mode?
  end

  def previously_spun?(test_name, choices)
    whiplash_session.key?(test_name) && choices.include?(whiplash_session[test_name])
  end

  def all_whiplash_tests(goal)
    REDIS.smembers("whiplash/goals/#{goal}")
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

  def data_for_options(test_name, choices)
    loptions = {}
    choices.each { |choice| 
      loptions[choice] = [
        REDIS.get("whiplash/#{test_name}/#{choice}/spins").to_i,
        REDIS.get("whiplash/#{test_name}/#{choice}/wins").to_i
      ]
    }
    loptions
  end
  
  def log(test_name, choice, type)
    message = "WHIPLASH: " + { type: type, when: Time.now.to_f, test: test_name, choice: choice }.to_json
    if defined?(Rails)
      Rails.logger.info message
    else
      puts message
    end
  end

  def arm_guess(observations, victories)
    a = [victories, 0].max
    b = [observations-victories, 0].max
    s = SimpleRandom.new; s.set_seed; s.beta(a+FC7, b+FC7)
  end

  def spin_for_choice!(test_name, choices)
    choice = best_guess(data_for_options(test_name, choices))
    REDIS.incr("whiplash/#{test_name}/#{choice}/spins")
    log test_name, choice, 'spin'
    whiplash_session[test_name] = choice
    choice
  end

end
