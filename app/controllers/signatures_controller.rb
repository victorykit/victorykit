require 'sent_email_hasher'
require 'signature_hasher'

class SignaturesController < ApplicationController
  def create
    petition = Petition.find(params[:petition_id])
    signature = Signature.new(params[:signature])
    signature.ip_address = request.remote_ip
    signature.user_agent = request.env["HTTP_USER_AGENT"]
    signature.member = Member.find_or_initialize_by_email(email: signature.email, name: signature.name)
    signature.created_member = signature.member.new_record?
    if signature.valid?
      begin
        petition.signatures.push signature

        Notifications.signed_petition signature
        petition.save!

        nps_win signature
        record_email_reference(params[:email_hash], signature)
        record_facebook_reference(params[:fb_hash], signature)
        
        session[:signature_name] = signature.name
        session[:signature_email] = signature.email
        session[:last_signature_id] = signature.id

        cookie = cookies[:signed_petitions] || ""
        signed_petitions = cookie.split "|"
        signed_petitions.push petition.id
        cookies[:signed_petitions] = signed_petitions.join "|"
        win! :signature
      rescue => ex
        flash.notice = ex.message
      end
    else
      flash[:invalid_signature] = signature
    end
    flash[:user_just_signed] = true
    redirect_to petition_url(petition)
  end

  private
  def record_email_reference hash, signature
    if h = SentEmailHasher.validate(hash)
      # update sent email table
      sent_email = SentEmail.find_by_id(h)
      sent_email.signature_id ||= signature.id
      sent_email.email_experiments.each {|e| win_on_option!(e.key, e.choice)}
      sent_email.save!
      # update reference in signature table
      signature.reference_type = Signature::ReferenceType::EMAIL
      signature.referer_id = sent_email.member_id
      signature.save!
    end
  end

  def record_facebook_reference hash, signature
    if h = SignatureHasher.validate(hash)
      referers_signature = Signature.find(h)
      signature.reference_type = Signature::ReferenceType::FACEBOOK
      signature.referer_id = referers_signature.member_id
      signature.save!
    end
  end

  def nps_win signature
    if signature.created_member
      win_on_option!("email_scheduler_nps", signature.petition.id.to_s)
    end
  end
end
