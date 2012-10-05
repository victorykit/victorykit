class SignaturesController < ApplicationController
  def create
    petition = Petition.find(params[:petition_id])
    signature = Signature.new(params[:signature])
    signature.ip_address = connecting_ip
    signature.user_agent = browser.user_agent
    signature.browser_name = browser.id.to_s
    signature.member = Member.find_or_initialize_by_email(email: signature.email, first_name: signature.first_name, last_name: signature.last_name)
    signature.created_member = signature.member.new_record?
    signature.http_referer = retrieve_http_referer

    member_hash = nil
    if signature.valid?
      begin
        petition.signatures.push signature
        petition.save!
        track_referrals petition, signature
        signature.save!

        begin
          Resque.enqueue(SignedPetitionEmailJob, signature.id)
        rescue => ex
          Rails.logger.error "Error queueing email on Resque: #{ex} #{ex.backtrace.join}"
          Notifications.signed_petition Signature.find(signature.id)
        end

        nps_win signature
        win! :signature
        member_hash = signature.member.to_hash
        cookies[:member_id] = { :value => member_hash, :expires => 100.years.from_now }
        flash[:signature_id] = signature.id
      rescue => ex
        Rails.logger.error "Error saving signature: #{ex} #{ex.backtrace.join}"
        flash.notice = ex.message
      end
    end

    respond_to do |format|
      format.json { 
        if signature.valid?
          render json: { signature_id: signature.id, url: petition_url(petition, l: member_hash), member: signature.member.attributes.slice(:first_name, :last_name, :email) } 
        else
          render json: signature.errors, status: 400
        end
      }
      format.html { 
        flash[:invalid_signature] = signature unless signature.valid?
        redirect_to petition_url(petition, l: member_hash) 
      }
    end
  end

  
  private

  def track_referrals petition, signature
    track_regular_referral(petition, signature) || track_facebook_referral(petition, signature)
  end

  def referral_params(possible_types)
    param_name     = possible_types.keys.find { |k| params[k].present? }
    reference_type = possible_types[param_name]
    received_code  = params[param_name]

    return param_name, reference_type, received_code
  end

  def track_regular_referral petition, signature
    param_name, reference_type, received_code = referral_params(ref_types)
    return nil if param_name.nil?

    if param_name == :email_hash
      sent_email = SentEmail.find_by_hash(received_code)
      sent_email.signature ||= signature
      sent_email.save!
      petition.experiments.email(sent_email).win!(:signature)

      signature.attributes = {
        referer: sent_email.member,
        reference_type: reference_type
      }
    else
      referring_member = Member.find_by_hash(received_code)
      signature.attributes = {
        referer: referring_member,
        reference_type: reference_type,
        referring_url: params[:referring_url]
      }
    end
  end

  def code_and_member_for_facebook_share_special_case(received_code, petition_id)
    facebook_action = Share.find_by_action_id(received_code.to_s)
    code = ReferralCode.where(petition_id: petition_id, member_id: facebook_action.member_id).first

    return code, facebook_action.member
  end

  def code_and_member_for_legacy_referral_code(received_code, petition_id)
    member = Member.find_by_hash(received_code)
    code = ReferralCode.where(petition_id: petition_id, member_id: member.id).first

    return code, member
  end

  def code_and_member_for_generated_referral_code(received_code)
    code = ReferralCode.where(code: received_code).first

    return code, code.try(:member)
  end

  def track_facebook_referral petition, signature
    param_name, reference_type, received_code = referral_params(facebook_ref_types)
    return nil if param_name.nil?

    code, referring_member = if param_name == :fb_action_id
      code_and_member_for_facebook_share_special_case received_code, petition.id
    elsif received_code =~ /^(\d+)\.(.*?)$/
      code_and_member_for_legacy_referral_code received_code, petition.id
    else
      code_and_member_for_generated_referral_code received_code
    end

    code.try(:win!, :signature)

    signature.attributes = {
      referer: referring_member,
      reference_type: reference_type,
      referring_url: params[:referring_url]
    }
  end

  def nps_win signature
    return unless signature.created_member
    win_on_option!('email_scheduler_nps', signature.petition.id.to_s)
  
    reference = signature.reference_type
    return unless reference && facebook_ref_types.values.include?(reference)
    if(reference == 'facebook_request' || reference == 'facebook_autofill_request')
      win_on_option!('facebook request pick vs autofill', reference)
      reference = 'facebook_request'
    end
    win_on_option!('facebook sharing options', reference)
  end

  def ref_types
    {
      email_hash: Signature::ReferenceType::EMAIL,
      forwarded_notification_hash: Signature::ReferenceType::FORWARDED_NOTIFICATION,
      shared_link_hash: Signature::ReferenceType::SHARED_LINK,
      twitter_hash: Signature::ReferenceType::TWITTER
    }
  end

  def facebook_ref_types
    {
      fb_action_id: Signature::ReferenceType::FACEBOOK_SHARE,
      fb_like_hash: Signature::ReferenceType::FACEBOOK_LIKE,
      fb_share_link_ref: Signature::ReferenceType::FACEBOOK_POPUP, 
      fb_dialog_request: Signature::ReferenceType::FACEBOOK_REQUEST, 
      fb_autofill_request: Signature::ReferenceType::FACEBOOK_AUTOFILL_REQUEST,
      fb_wall_hash: Signature::ReferenceType::FACEBOOK_WALL,
      fb_recommendation_ref: Signature::ReferenceType::FACEBOOK_RECOMMENDATION
    }
  end
end
