class SignaturesController < ApplicationController
  def create
    petition = Petition.find params[:petition_id]
    signature = Signature.new(params[:signature])
    signature.ip_address = request.remote_ip
    signature.user_agent = request.env["HTTP_USER_AGENT"]
    petition.signatures.push(signature)
    petition.save
    render
  end
end
