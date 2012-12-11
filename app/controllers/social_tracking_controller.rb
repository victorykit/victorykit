class SocialTrackingController < ApplicationController
  def create
    action = params[:facebook_action]
        
    if action == "status"
      register_facebook_status
    else
      win! :share
      
      @petition = Petition.find params[:petition_id]
      @member = Signature.find(params[:signature_id]).member if params[:signature_id].present?
      @facebook_uid = params[:facebook_uid]
      @action_id = params[:action_id]
      @request_id = params[:request_id]
      @friend_ids = params[:friend_ids]
      
      record_facebook_uid

      send({
        'like' => :register_facebook_like,
        'share' => :register_facebook_share,
        'popup' => :register_facebook_popup_opened,
        'dialog' => :register_facebook_dialog,
        'request' => :register_facebook_request,
        'recommend' => :register_recommendation
      }[action])
    end
    
    render :text => ''
  end

  private
  
  def record_facebook_uid
    begin
      if should_record_facebook_uid
        @member.facebook_uid = @facebook_uid
        @member.save!
      end
    rescue => ex
      Rails.logger.error "error while saving facebook user id: #{ex} #{ex.backtrace.join('\n')}"
    end
  end

  def should_record_facebook_uid
    @member.present? and @member.facebook_uid.nil? and !@facebook_uid.blank? and @facebook_uid != '0'
  end

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

  def register_recommendation
    recommendation = FacebookRecommendation.new
    recommendation.petition = @petition
    recommendation.member = @member if @member.present?
    recommendation.save!
  end
end
