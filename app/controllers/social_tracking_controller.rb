class SocialTrackingController < ApplicationController
  def create
    action = params[:facebook_action]
        
    if action == "status"
      register_facebook_status
    else
      win! :share
      
      @petition = Petition.find params[:petition_id]
      @member = Signature.find(params[:signature_id]).member if params[:signature_id].present?
      @action_id = params[:action_id]
      @request_id = params[:request_id]
      @friend_ids = params[:friend_ids]
      
      send({
        'like' => :register_facebook_like,
        'share' => :register_facebook_share,
        'popup' => :register_facebook_popup_opened,
        'dialog' => :register_facebook_dialog,
        'request' => :register_facebook_request,
        'autofill_request' => :register_autofill_request,
        'recommend' => :register_recommendation
      }[action])
    end
    
    render :text => ''
  end

  private
  
  def register_facebook_status
    REDIS.incr("fbtrack/#{params[:facebook_status]}")
  end

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
    popup = Popup.new
    popup.petition = @petition
    popup.member = @member if @member.present?
    popup.save!
  end

  def register_facebook_dialog
    dialog = Dialog.new
    dialog.petition = @petition
    dialog.member = @member if @member.present?
    dialog.save!
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

  def register_autofill_request
    request = FacebookAutofillRequest.new
    request.petition = @petition
    request.action_id = @request_id if @request_id.present?
    request.member = @member if @member.present?
    request.save!
  end

  def register_recommendation
    recommendation = FacebookRecommendation.new
    recommendation.petition = @petition
    recommendation.member = @member if @member.present?
    recommendation.save!
  end
end
