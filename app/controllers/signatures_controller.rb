require 'sent_email_hasher'

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
        record_visitor(params[:email_hash], signature)
        
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
    end
		flash[:user_just_signed] = true
    redirect_to petition_url(petition)
  end

  private
  def record_visitor hash, signature
    if h = SentEmailHasher.validate(hash)
      sent_email = SentEmail.find_by_id(h)
      sent_email.signature_id ||= signature.id
      sent_email.email_experiments.each {|e| win_on_option!(e.key, e.choice)}
      sent_email.save!
    end
  end

  def nps_win signature
    if signature.created_member
      win_on_option!("email_scheduler_nps", signature.petition.id.to_s)
    end
  end
end
