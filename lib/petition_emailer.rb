#Finds a random member and chooses a petition to email them
class PetitionEmailer
  extend Whiplash
  
  def self.send
    member = Member.random_and_not_recently_contacted
    self.send_to member if member
  end

  def self.send_to member
    interesting = Petition.find_interesting_petitions_for(member)
    return unless interesting.any?

    id = self.spin_for interesting, member
    petition = Petition.find_by_id(id)
    ScheduledEmail.new_petition(petition, member)
  end

  private

  def self.spin_for petitions, member
    experiment = 'email_scheduler_nps'
    goal = :signatures_off_email
    options = petitions.map(&:id).map(&:to_s)
    session = { session_id: member.id }

    option = spin! experiment, goal, options, session
    option.to_i # the petition id
  end

end