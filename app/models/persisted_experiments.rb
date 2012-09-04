module PersistedExperiments
  include Whiplash

  def win!(goal)
    current_trials(goal).each { |trial| win_on_option!(trial.key, trial.choice, trial_session) }
  end

  private

  alias super_spin! spin!

  def spin!(test_name, goal, options=[true, false], default=nil)
    return default if not options.any?

    current = current_trial(goal, test_name)
    return current.choice if current

    choice = super_spin!(test_name, goal, options, trial_session)
    create_trial(goal, test_name, choice).save! unless options.count < 2
    choice
  end

  # templates

  def current_trials(goal)
    raise 'implement'
  end

  def current_trial(goal, test_name)
    raise 'implement'
  end

  def create_trial(goal, test_name, choice)
    raise 'implement'
  end

  def trial_session
    raise 'implement'
  end

end
