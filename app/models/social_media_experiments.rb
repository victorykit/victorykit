class SocialMediaExperiments
  include Bandit 
  
  def initialize(petition, member)
    @petition = petition
    @member = member
  end

  def win!
    trials = SocialMediaTrial.find_all_by_petition_id_and_member_id_and_key(@petition.id, @member.id, test_names.values)
    trials.each { |trial| win_on_option!(trial.key, trial.choice, trial_session) }
  end

  private

  def do_spin!(test_name, goal, options)
    existing = SocialMediaTrial.find_by_member_id_and_petition_id_and_key @member.id, @petition.id, test_name
    existing ? existing.choice : new_spin!(test_name, goal, options).choice
  end

  def new_spin!(test_name, goal, options)
    choice = spin!(test_name, goal, options, trial_session)
    trial = SocialMediaTrial.new(
      member_id: @member.id, petition_id: @petition.id, goal: goal, key: test_name, choice: choice)
    trial.save!
    trial
  end

  def trial_session
    {:session_id => @member.id.to_s}
  end

end