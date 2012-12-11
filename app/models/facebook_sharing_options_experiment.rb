class FacebookSharingOptionsExperiment < TimeBandedExperiment

  def initialize whiplash
    super('facebook sharing options', [Time.parse("2012-Nov-02 11:30 -0400")])

    @options = ['facebook_popup', 'facebook_request', 'facebook_recommendation', 'facebook_dialog']
    @whiplash = whiplash
  end

  def spin! member, browser
    return 'facebook_popup' if browser.ie7?

    sharing_option = @whiplash.spin! name_as_of(Time.now), :referred_member, @options
  end

  def self.applicable_to? signature
    referral_type = signature.reference_type
    return referral_type && SignatureReferral::FACEBOOK_REF_TYPES.values.include?(referral_type)
  end

  def win! signature
    @whiplash.win_on_option! name_as_of_referral(signature), signature.reference_type
  end

  private

  def name_as_of_referral signature
    referral = signature.referral
    referral_time = referral.created_at if referral
    name = name_as_of referral_time
    if not referral_time
      Rails.logger.debug("Referral time unknown: '+
        'no referer_id for signature #{signature.id}. '+
        'Awarding win for #{signature.reference_type} to default test: #{name}")
    end
    name
  end

end
