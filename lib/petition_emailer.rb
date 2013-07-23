#Finds a random member and chooses a petition to email them
class PetitionEmailer
  def self.send(n)
    Member.random_and_not_recently_contacted(n).select do |member|
      unlocked? member
    end.each do |member|
      self.send_to member if member
    end
  end

  def self.send_to member
    # TODO if no interesting petitions are found then an email isn't sent and
    #      the count returned above for # of emails sent is incorrect.
    interesting = Petition.find_interesting_petitions_for(member)
    return unless interesting.any?
    ScheduledPetitionEmailJob.perform_async(member.id, interesting.map(&:id))
  end

  private

  def self.unlocked?(member)
    k = "scheduled_email/sent/#{member.id}"
    if REDIS.incr(k) == 1
      REDIS.expire(k, 60*60)
      true
    else
      false
    end
  end

end
