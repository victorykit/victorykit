class SocialTrackingController < ApplicationController
  def new
    win! :share
    facebook_action = params[:facebook_action]
    petition = Petition.find params[:petition_id]
    member = Signature.find(params[:signature_id]).member if params[:signature_id].present?
    if facebook_action == 'like'
      register_facebook_like petition, member
    end
    render :text => ''
  end

  private

  def register_facebook_like petition, member
    like = Like.new
    like.petition = petition
    like.member = member if member.present?
    like.save!
  end
end
