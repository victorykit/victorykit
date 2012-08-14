class SocialTrackingController < ApplicationController
  def new
    win! :share
    
    @petition = Petition.find params[:petition_id]
    @member = Signature.find(params[:signature_id]).member if params[:signature_id].present?
    @action_id = params[:action_id]
    @request_id = params[:request_id]
    @friend_ids = params[:friend_ids]
    
    action = params[:facebook_action]
    
    send({
      'like' => :register_facebook_like,
      'share' => :register_facebook_share,
      'popup' => :register_facebook_popup_opened,
      'wall' => :register_facebook_wall,
      'request' => :register_facebook_request
    }[action])
    
    render :text => ''
  end

  private

  def register_facebook_like
    like = Like.new
    like.petition = @petition
    like.member = @member if @member.present?
    like.save!
  end

  def register_facebook_share
    share = Share.new
    share.petition = @petition
    share.action_id = @action_id if @action_id.present?
    share.member = @member if @member.present?
    share.save!
  end

  def register_facebook_popup_opened
    share = Popup.new
    share.petition = @petition
    share.member = @member if @member.present?
    share.save!
  end

  def register_facebook_wall
    wall = FacebookWall.new
    wall.petition = @petition
    wall.member = @member if @member.present?
    wall.save!
  end

  def register_facebook_request
    request = FacebookRequest.new
    request.petition = @petition
    request.action_id = @request_id if @request_id.present?
    request.member = @member if @member.present?
    request.save!
    @friend_ids.each do |facebook_id|      
      if @member.present?  
        friend = FacebookFriend.where(member_id: @member.id, facebook_id: facebook_id).first
        new_facebook_friend = FacebookFriend.new(member_id: @member.id, facebook_id: facebook_id) unless friend
        new_facebook_friend.save! if new_facebook_friend.present?    
      end
    end
  end
  
end
