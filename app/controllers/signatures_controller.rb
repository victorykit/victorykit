require 'hasher'

class SignaturesController < ApplicationController
  def create
    petition = Petition.find(params[:petition_id])
    signature = Signature.new(params[:signature])
    signature.ip_address = request.remote_ip
    signature.user_agent = request.env["HTTP_USER_AGENT"]
    signature.member = Member.find_or_create_by_email(email: signature.email, name: signature.name)
    signature.created_member = signature.member.id.nil?
    if signature.valid?
      petition.signatures.push signature
      petition.save!
      if h = Hasher.validate(params[:email_hash])
        sent_email = SentEmail.find_by_id(h)
        sent_email.signature_id ||= signature.id
        sent_email.save!
        win_on_option!("email_scheduler", petition.id.to_s, {session_id: signature.member.id})
      end
      session[:signature_name] = signature.name
      session[:signature_email] = signature.email
      cookie = cookies[:signed_petitions] || ""
      signed_petitions = cookie.split "|"
      signed_petitions.push petition.id
      cookies[:signed_petitions] = signed_petitions.join "|"
      win! :signature
      Notifications.signed_petition signature
      redirect_to petition_url(petition)
      
    else
      @petition = petition
      @signature = signature
      render :template => "petitions/show"
    end
  end
end
