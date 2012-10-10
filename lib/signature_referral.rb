class SignatureReferral

  REF_TYPES = {
    n:             Signature::ReferenceType::EMAIL,
    r:             Signature::ReferenceType::FORWARDED_NOTIFICATION,
    l:             Signature::ReferenceType::SHARED_LINK,
    t:             Signature::ReferenceType::TWITTER
  }.with_indifferent_access

  FACEBOOK_REF_TYPES = {
    f:             Signature::ReferenceType::FACEBOOK_LIKE,
    share_ref:     Signature::ReferenceType::FACEBOOK_POPUP,
    d:             Signature::ReferenceType::FACEBOOK_REQUEST,
    autofill:      Signature::ReferenceType::FACEBOOK_AUTOFILL_REQUEST,
    recommend_ref: Signature::ReferenceType::FACEBOOK_RECOMMENDATION,
    fb_action_ids: Signature::ReferenceType::FACEBOOK_SHARE
  }.with_indifferent_access

  ALL_REF_TYPES = REF_TYPES.merge(FACEBOOK_REF_TYPES)

  attr_reader :petition, :signature, :params, :reference_type, :received_code, :referral_type, :referring_url

  def initialize(petition, signature, params = {})
    @petition       = petition
    @signature      = signature
    @referring_url  = params[:referring_url]
    @received_code  = params[:referer_ref_code]
    @reference_type = params[:referer_ref_type]
    @referral_type  = trackable? && ( REF_TYPES.values.include?(@reference_type) ? :regular : :facebook )
  end

  def trackable?
    @reference_type.present? && @received_code.present?
  end

  def referral
    return {} unless trackable?
    @referral_type == :regular ? track_regular_referral : track_facebook_referral
  end

  def self.translate_raw_referral(params={})
    raw_referer_ref_type = ( params.keys & ALL_REF_TYPES.keys ).first.try(:to_sym)
    ref_type = ALL_REF_TYPES[raw_referer_ref_type]
    ref_code = params[raw_referer_ref_type]

    return ref_type, ref_code
  end

  private

  def track_regular_referral
    if reference_type == Signature::ReferenceType::EMAIL
      sent_email = SentEmail.find_by_hash(received_code)
      sent_email.signature ||= signature
      sent_email.save!
      petition.experiments.email(sent_email).win!(:signature)

      {
        referer: sent_email.member,
        reference_type: reference_type
      }
    else
      referring_member = Member.find_by_hash(received_code)
      
      {
        referer: referring_member,
        reference_type: reference_type,
        referring_url: referring_url
      }
    end
  end

  def code_and_member_for_facebook_share_special_case
    facebook_action = Share.find_by_action_id(received_code.to_s)
    code = ReferralCode.where(petition_id: petition.id, member_id: facebook_action.member_id).first

    return code, facebook_action.member
  end

  def code_and_member_for_legacy_referral_code
    member = Member.find_by_hash(received_code)
    code = ReferralCode.where(petition_id: petition.id, member_id: member.id).first

    return code, member
  end

  def code_and_member_for_generated_referral_code
    code = ReferralCode.where(code: received_code).first

    return code, code.try(:member)
  end

  def track_facebook_referral
    $statsd.increment "facebook_referrals.count"

    code, referring_member = if reference_type == Signature::ReferenceType::FACEBOOK_SHARE
      code_and_member_for_facebook_share_special_case
    elsif received_code =~ /^(\d+)\.(.*?)$/
      code_and_member_for_legacy_referral_code
    else
      code_and_member_for_generated_referral_code
    end

    code.try(:win!, :signature)

    {
      referer: referring_member,
      reference_type: reference_type,
      referring_url: referring_url
    }
  end

end
