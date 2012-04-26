class SignaturesController < ApplicationController
  def create
    petition = Petition.find(params[:petition_id])
    signature = Signature.new(params[:signature])
    signature.ip_address = request.remote_ip
    signature.user_agent = request.env["HTTP_USER_AGENT"]
    if(signature.valid?)
      petition.signatures.push(signature)     
      session[:signed_petitions] ||= []
      session[:signed_petitions] << petition.id
      redirect_to petition_url(petition)
    else
      @petition = petition
      render :template => "petitions/show"
    end
  end
end
