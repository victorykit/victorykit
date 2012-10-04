class PetitionExperiments
  def initialize(petition)
    @petition = petition
  end

  def facebook(member)
    FacebookExperiments.new(@petition, member)
  end

  def email(email)
    EmailExperiments.new(email)
  end

end
