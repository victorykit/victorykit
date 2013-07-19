class SignedPetitionEmailJob
  include Sidekiq::Worker

  def perform(signature_id)
    Notifications.signed_petition Signature.find(signature_id)
  end
end