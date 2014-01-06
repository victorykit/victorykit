class GeoLocateSignatureJob
  include Sidekiq::Worker

  def perform(signature_id)
    Signature.transaction do 
      sig = Signature.find_by_id(signature_id)

      return if sig.nil?

      loc = Geocoder.search(sig.ip_address).first 

      return if loc.nil?

      sig.city         = loc.city         if loc.city.present?
      sig.metrocode    = loc.metrocode    if loc.metrocode.present?
      sig.state        = loc.state        if loc.state.present?
      sig.state_code   = loc.state_code   if loc.state_code.present?
      sig.country_code = loc.country_code if loc.country_code.present?
      
      sig.member.state_code   = loc.state_code   if loc.state_code.present?
      sig.member.country_code = loc.country_code if loc.country_code.present?

      sig.save!
    end
  end

end
