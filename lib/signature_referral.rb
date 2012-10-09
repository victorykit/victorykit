class SignatureReferral

  REF_TYPES = {
    email_hash: Signature::ReferenceType::EMAIL,
    forwarded_notification_hash: Signature::ReferenceType::FORWARDED_NOTIFICATION,
    shared_link_hash: Signature::ReferenceType::SHARED_LINK,
    twitter_hash: Signature::ReferenceType::TWITTER
  }.with_indifferent_access

  FACEBOOK_REF_TYPES = {
    fb_action_id: Signature::ReferenceType::FACEBOOK_SHARE,
    fb_like_hash: Signature::ReferenceType::FACEBOOK_LIKE,
    fb_share_link_ref: Signature::ReferenceType::FACEBOOK_POPUP, 
    fb_dialog_request: Signature::ReferenceType::FACEBOOK_REQUEST, 
    fb_autofill_request: Signature::ReferenceType::FACEBOOK_AUTOFILL_REQUEST,
    fb_recommendation_ref: Signature::ReferenceType::FACEBOOK_RECOMMENDATION
  }.with_indifferent_access

  ALL_REF_TYPES = REF_TYPES.merge(FACEBOOK_REF_TYPES)

  attr_reader :petition, :signature, :params, :param_name, :reference_type, :received_code, :referral_type, :referring_url

  def initialize(petition, signature, params = {})
    @petition       = petition
    @signature      = signature
    @referring_url  = params[:referring_url]
    @param_name     = ( params.keys & ALL_REF_TYPES.keys ).first.try(:to_sym)
    @received_code  = params[@param_name]
    @reference_type = ALL_REF_TYPES[@param_name]
    @referral_type  = trackable? && ( REF_TYPES.has_key?(@param_name) ? :regular : :facebook )
  end

  def trackable?
    @param_name.present? && @received_code.present?
  end

  def referral
    return {} unless trackable?
    @referral_type == :regular ? track_regular_referral : track_facebook_referral
  end

  private

  def track_regular_referral
    if param_name == :email_hash
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

    code, referring_member = if param_name == :fb_action_id
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
