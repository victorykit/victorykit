class ScheduledPetitionEmailJob
  include Sidekiq::Worker
  include Whiplash

  def perform(member_id, petition_ids)
    petition = spin_for_petition(member_id, petition_ids)
    member = Member.find(member_id)
    ScheduledMailer.new_petition(petition, member)
  end

  private

  def spin_for_petition(member_id, petition_ids)
    experiment = 'email_scheduler_nps'
    goal = :signatures_off_email
    options = petition_ids.map &:to_s
    session = { session_id: member_id }
    chosen_petition_id = spin! experiment, goal, options, session
    Petition.find(chosen_petition_id)
  end

end
