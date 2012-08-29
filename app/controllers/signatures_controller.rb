require 'sent_email_hasher'
require 'member_hasher'

class SignaturesController < ApplicationController
  def create
    petition = Petition.find(params[:petition_id])
    signature = Signature.new(params[:signature])
    signature.ip_address = connecting_ip
    signature.user_agent = request.env["HTTP_USER_AGENT"]
    signature.browser_name = Browser.new(:ua => signature.user_agent).id.to_s
    signature.member = Member.find_or_initialize_by_email(email: signature.email, first_name: signature.first_name, last_name: signature.last_name)
    signature.created_member = signature.member.new_record?
    member_hash = nil
    if signature.valid?
      begin
        petition.signatures.push signature
        petition.save!
        track_referrals petition, signature
        signature.save!

        begin
          Resque.enqueue(SignedPetitionEmailJob, signature.id)
        rescue => ex
          Rails.logger.error "Error queueing email on Resque: #{ex} #{ex.backtrace.join}"
          Notifications.signed_petition Signature.find(signature.id)
        end

        nps_win signature
        win! :signature
        member_hash = signature.member.to_hash
        cookies[:member_id] = { :value => member_hash, :expires => 100.years.from_now }
        flash[:signature_id] = signature.id
      rescue => ex
        Rails.logger.error "Error saving signature: #{ex} #{ex.backtrace.join}"
        flash.notice = ex.message
      end
    else
      flash[:invalid_signature] = signature
    end
    redirect_to petition_url(petition, l: member_hash)
  end

  
  private

  def track_referrals petition, signature
    track_regular_referral(petition, signature) || track_facebook_referral(petition, signature)
  end

  def track_regular_referral petition, signature
    ref_types.keys.find do |key| 
      (key == :email_hash) ? 
      deal_with_email_special_case(petition, signature) : 
      record_referer(signature, key, ref_types[key])
    end
  end

  def track_facebook_referral petition, signature
    facebook_ref_types.keys.find do |key|
      if key == :fb_action_id
        deal_with_facebook_share_special_case(petition, signature)
      else  
        found = record_referer(signature, key, facebook_ref_types[key])
        petition.experiments.facebook(found).win!(:signature) if found
        found
      end
    end  
  end

  def record_referer signature, param_name, reference_type
    referring_member = Member.find_by_hash(params[param_name])
    return unless referring_member

    signature.attributes = {
      referer: referring_member, 
      reference_type: reference_type, 
      referring_url: params[:referring_url]
    }
    referring_member
  end

  def nps_win signature
    return unless signature.created_member
    win_on_option!('email_scheduler_nps', signature.petition.id.to_s)
  
    reference = signature.reference_type
    return unless reference && facebook_ref_types.values.include?(reference)
    win_on_option!('facebook sharing options', reference)
  end

  def ref_types
    {
      email_hash: Signature::ReferenceType::EMAIL,
      forwarded_notification_hash: Signature::ReferenceType::FORWARDED_NOTIFICATION,
      shared_link_hash: Signature::ReferenceType::SHARED_LINK,
      twitter_hash: Signature::ReferenceType::TWITTER
    }
  end

  def facebook_ref_types
    {
      fb_action_id: Signature::ReferenceType::FACEBOOK_SHARE,
      fb_like_hash: Signature::ReferenceType::FACEBOOK_LIKE,
      fb_share_link_ref: Signature::ReferenceType::FACEBOOK_POPUP, 
      fb_dialog_request: Signature::ReferenceType::FACEBOOK_REQUEST, 
      fb_wall_hash: Signature::ReferenceType::FACEBOOK_WALL
    }
  end

  def deal_with_facebook_share_special_case petition, signature
    return unless params[:fb_action_id].present?
    facebook_action = Share.find_by_action_id(params[:fb_action_id].to_s)
    referring_member = facebook_action.member
    
    signature.attributes = {
      referer: referring_member, 
      reference_type: facebook_ref_types[:fb_action_id], 
      referring_url: params[:referring_url]
    }
    
    petition.experiments.facebook(referring_member).win!(:signature)
    true
  end

  def deal_with_email_special_case petition, signature
    return unless sent_email = SentEmail.find_by_hash(params[:email_hash])
    sent_email.signature ||= signature
    sent_email.save!
    
    signature.attributes = {
      referer: sent_email.member, 
      reference_type: ref_types[:email_hash]
    }

    petition.experiments.email(sent_email).win!(:signature)
    true
  end
end
