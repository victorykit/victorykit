class PetitionExperiments
  def initialize(petition)
    @petition = petition
  end

  def facebook(member)
    FacebookExperiments.new(@petition, member)
  end

end