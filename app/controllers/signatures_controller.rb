class SignaturesController < ApplicationController
  def create
    petition = Petition.find(params[:petition_id])
    signature = Signature.new(params[:signature])
    signature.ip_address = connecting_ip
    signature.user_agent = browser.user_agent
    signature.browser_name = browser.id.to_s
    signature.member = Member.find_or_initialize_by_email(signature.email).tap do |m|
      m.first_name = signature.first_name
      m.last_name = signature.last_name
    end
    signature.created_member = signature.member.new_record?
    signature.member.save
    signature.http_referer = retrieve_http_referer
    ref_code = ReferralCode.where(code: params[:signer_ref_code]).first || ReferralCode.new(code: params[:signer_ref_code])

    if signature.valid?
      begin
        petition.signatures.push signature
        petition.save!
        signature.track_referrals(params)
        signature.save!
        ref_code.member_id = signature.member.id
        ref_code.petition_id = petition.id
        ref_code.save!

        begin
          Resque.enqueue(SignedPetitionEmailJob, signature.id)
        rescue => ex
          notify_airbrake(ex)
          Rails.logger.error "Error queueing email on Resque: #{ex} #{ex.backtrace.join}"
          Notifications.signed_petition Signature.find(signature.id)
        end

        nps_win signature
        win! :signature
        cookies[:member_id] = { :value => signature.member.to_hash, :expires => 100.years.from_now }

        flash[:signature_id] = signature.id
      rescue => ex
        notify_airbrake(ex)
        Rails.logger.error "Error saving signature: #{ex} #{ex.backtrace.join}"
        flash.notice = ex.message
      end
    end

    respond_to do |format|
      format.json { 
        if signature.valid?
          render json: { signature_id: signature.id, url: petition_url(petition, l: ref_code.code), member: signature.member.attributes.slice(:first_name, :last_name, :email) }
        else
          render json: signature.errors, status: 400
        end
      }
      format.html { 
        flash[:invalid_signature] = signature unless signature.valid?
        redirect_to petition_url(petition, l: signature.valid? ? ref_code.code : nil)
      }
    end
  end

  private
  
  def nps_win signature
    return unless signature.created_member
    win_on_option!('email_scheduler_nps', signature.petition.id.to_s)
  
    reference = signature.reference_type
    return unless reference && SignatureReferral::FACEBOOK_REF_TYPES.values.include?(reference)
    if(reference == 'facebook_request' || reference == 'facebook_autofill_request')
      win_on_option!('facebook request pick vs autofill', reference)
      reference = 'facebook_request'
    end
    win_on_option!('facebook sharing options', reference)
  end
end
