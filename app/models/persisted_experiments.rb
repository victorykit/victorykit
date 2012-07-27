module PersistedExperiments
  include Bandit

  def win!(goal)
    current_trials(goal).each { |trial| win_on_option!(trial.key, trial.choice, trial_session) }
  end

  private

  def spin_or_default!(test_name, goal, options, default)
    return default if not options.any?
    spin_or_retrieve_choice test_name, goal, options
  end

  def spin_or_retrieve_choice test_name, goal, options
    current = current_trial(goal, test_name)
    current ? current.choice : spin_new!(test_name, goal, options, trial_session)
  end

  def spin_new!(test_name, goal, options, mysession)
    choice = spin!(test_name, goal, options, mysession)
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
