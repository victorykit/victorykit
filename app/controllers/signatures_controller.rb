class SignaturesController < ApplicationController
  def create
    petition = Petition.find(params[:petition_id])
    signature = Signature.new(params[:signature])
    signature.ip_address = request.remote_ip
    signature.user_agent = request.env["HTTP_USER_AGENT"]
    if signature.valid?
      petition.signatures.push signature
      cookie = cookies[:signed_petitions] || ""     
      signed_petitions = cookie.split "|"
      signed_petitions.push petition.id
      cookies[:signed_petitions] = signed_petitions.join "|"
      EmailGateway.send_email({from: "signups@victorykit.com", to: signature.email, subject: "Thanks for signing #{petition.title}", body: "Please encourage your friends to sign it too!"})
      redirect_to petition_url(petition)
      
    else
      @petition = petition
      @signature = signature
      render :template => "petitions/show"
    end
  end
end
