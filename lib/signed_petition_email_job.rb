class SignedPetitionEmailJob
  @queue = :signed_petition_emails

  def self.perform(signature_id)
    Notifications.signed_petition Signature.find(signature_id)
  end
end