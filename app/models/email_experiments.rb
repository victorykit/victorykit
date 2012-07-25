class EmailExperiments
  include PersistedExperiments

  def initialize(email)
    @email = email
  end

  def subject
    default = @email.petition.title
    spin_or_default!(test_names[:subject], :signature, title_options.map{|opt| opt.title}, default)
  end

  private

  def title_options
    PetitionTitle.find_all_by_petition_id_and_title_type(@email.petition.id, title_type)
  end

  def title_type
    PetitionTitle::TitleType::EMAIL
  end

  def test_names
    { :subject => "petition #{@email.petition.id} #{title_type} title" }
  end

  # persisted experiments templates

  def current_trials(goal)
    EmailExperiment.find_all_by_sent_email_id_and_goal_and_key(@email.id, goal, test_names.values)
  end

  def current_trial(goal, test_name)
    EmailExperiment.find_by_sent_email_id_and_goal_and_key(@email.id, goal, test_name)
  end

  def create_trial(goal, test_name, choice)
    EmailExperiment.new(sent_email_id: @email.id, goal: goal, key: test_name, choice: choice)
  end

  def trial_session
    {:session_id => @email.id.to_s}
  end

end
