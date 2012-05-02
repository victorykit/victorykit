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
