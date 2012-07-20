module PersistedExperiments
  include Bandit

  def win!(goal)
    current_trials(goal).each { |trial| win_on_option!(trial.key, trial.choice, trial_session) }
  end

  private

  def spin_or_default!(test_name, goal, options, default)
    return default if not options.any?
    current = current_trial(goal, test_name)
    current ? current.choice : new_trial!(test_name, goal, options).choice
  end

  def new_trial!(test_name, goal, options)
    choice = spin!(test_name, goal, options, trial_session)
    trial = create_trial(goal, test_name, choice)
    trial.save!
    trial
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