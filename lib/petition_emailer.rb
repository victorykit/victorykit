#Finds a random member and chooses a petition to email them
class PetitionEmailer
  extend Whiplash
  
  def self.send(n)
    to_contact = Member.random_and_not_recently_contacted(n).select do |member|
        k = "scheduled_email/sent/#{member.id}"
        if REDIS.incr(k) == 1
            REDIS.expire(k, 60*60)
            next true
        else
            next false
        end
    end

    to_contact.each  do |member|
      self.send_to member if member
    end
  end

  def self.send_to member
    interesting = Petition.find_interesting_petitions_for(member)
    return unless interesting.any?
    
    id = self.spin_for interesting, member
    petition = Petition.find_by_id(id)
    ScheduledMailer.new_petition(petition, member)
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