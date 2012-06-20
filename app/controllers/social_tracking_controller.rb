class SocialTrackingController < ApplicationController
  def new
	  win! :share
	  like = Like.new
	  like.petition = Petition.find params[:petition_id]
	  if signature_id = params[:signature_id]
	    like.member = Signature.find(signature_id).member
    end
		like.save!
    render :text => ''
  end
end