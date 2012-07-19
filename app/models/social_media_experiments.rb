class SocialMediaExperiments
  include PersistedExperiments
  
  def initialize(petition, member)
    @petition = petition
    @member = member
  end

  private

  # persisted experiments templates

  def current_trials
    SocialMediaTrial.find_all_by_petition_id_and_member_id_and_key(@petition.id, @member.id, test_names.values)
  end

  def current_trial(test_name)
    SocialMediaTrial.find_by_petition_id_and_member_id_and_key(@petition.id, @member.id, test_name)
  end

  def create_trial(goal, test_name, choice)
    SocialMediaTrial.new(member_id: @member.id, petition_id: @petition.id, goal: goal, key: test_name, choice: choice)
  end

  def trial_session
    {:session_id => @member.id.to_s}
  end

end