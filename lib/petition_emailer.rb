require 'whiplash'

#Finds a random member and chooses a petition to email them
class PetitionEmailer
  extend Bandit
  
  def self.send
    member = Member.random_and_not_recently_contacted
    if not member.nil?
      interesting_petitions = Petition.find_interesting_petitions_for(member)
      if interesting_petitions.any?
        petition_id = spin!("email_scheduler_nps", :signatures_off_email, options=interesting_petitions.map {|x| x.id.to_s}, {session_id: member.id}).to_i
        petition = Petition.find_by_id(petition_id)
        ScheduledEmail.new_petition(petition, member)
      end
    end
  end
end