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
        signature.track_referrals(petition, params)
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
