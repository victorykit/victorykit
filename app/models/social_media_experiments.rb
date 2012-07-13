class SocialMediaExperiments
  include Bandit 
  
  def initialize(petition, member)
    @petition = petition
    @member = member
  end

  private

  def do_spin!(test_name, goal, options)
    existing = SocialMediaTrial.find_by_member_id_and_petition_id_and_key @member.id, @petition.id, test_name
    existing ? existing.choice : new_spin!(test_name, goal, options).choice
  end

  def new_spin!(test_name, goal, options)
    session = {:session_id => @member.id.to_s}
    choice = spin!(test_name, goal, options, session)
    trial = SocialMediaTrial.new(
      member_id: @member.id, petition_id: @petition.id, goal: goal, key: test_name, choice: choice)
    trial.save!
    trial
  end
end