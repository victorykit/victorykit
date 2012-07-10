require 'whiplash'

class SocialMediaExperiment < ActiveRecord::Base
  attr_accessible :choice, :goal, :key, :member_id, :petition_id
  belongs_to :member
  belongs_to :petition
end

class SocialMediaSpinner
  include Bandit

  def do_spin!(member, petition, test_name, goal, options)
    existing = SocialMediaExperiment.find_by_member_id_and_petition_id_and_key member.id, petition.id, test_name
    return existing.choice if existing

    session = {:session_id => member.id.to_s}
    choice = spin!(test_name, goal, options, session)
    add_spin_data member, petition, goal, test_name, choice
    return choice
  end

  private

  def add_spin_data member, petition, goal, test_name, choice
    experiment = SocialMediaExperiment.new
    experiment.member_id = member.id
    experiment.petition_id = petition.id
    experiment.goal = goal
    experiment.key = test_name
    experiment.choice = choice
    experiment.save!
  end
end
