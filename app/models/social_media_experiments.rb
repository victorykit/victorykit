class SocialMediaExperiments
  include PersistedExperiments
  
  def initialize(petition, member)
    @petition = petition
    @member = member
  end

  private

  # persisted experiments templates

  def current_trials(goal)
    SocialMediaTrial.find_all_by_petition_id_and_member_id_and_goal_and_key(@petition.id, @member.id, goal, test_names.values)
  end

  def current_trial(goal, test_name)
    SocialMediaTrial.find_by_petition_id_and_member_id_and_goal_and_key(@petition.id, @member.id, goal, test_name)
  end

  def create_trial(goal, test_name, choice)
    SocialMediaTrial.new(petition_id: @petition.id, member_id: @member.id, goal: goal, key: test_name, choice: choice).tap do |t|
      # As a precursor to introducing this model between members and trials. Will add old codes as a one-off task.
      code = ReferralCode.find_or_create_by_code(code: @member.referral_code, petition_id: @petition.id, member_id: @member.id)

      t.referral_code = @member.referral_code
      t.referral_code_id = code.try(:id)
    end
  end

  def trial_session
    {:session_id => @member.id.to_s}
  end

end