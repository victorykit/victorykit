class SignaturesController < ApplicationController
  def create
    petition = Petition.find params[:petition_id]
    petition.signatures.push(Signature.new(params[:signature]))
    petition.save
    render
  end
end
