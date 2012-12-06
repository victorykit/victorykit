class PetitionExperiments

  def initialize(petition)
    @petition = petition
  end

  def facebook(member=nil)
    codes, member_id = @petition.referrals, member.try(:id)
    codes.where(member_id: member_id).first || @petition.referrals.build(member_id: member_id)
  end

  def email(email)
    EmailExperiments.new(email)
  end

end
