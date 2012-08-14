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
        Notifications.signed_petition signature
        petition.save!

        track_referrals petition, signature
        signature.save!
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
    if sent_email = SentEmail.find_by_hash(params[:email_hash])
      sent_email.signature ||= signature
      sent_email.save!
      signature.attributes = {referer: sent_email.member, reference_type: Signature::ReferenceType::EMAIL}
      petition.experiments.email(sent_email).win!(:signature)
    else
      if record_referer signature, :forwarded_notification_hash, Signature::ReferenceType::FORWARDED_NOTIFICATION
      elsif record_referer signature, :shared_link_hash, Signature::ReferenceType::SHARED_LINK
      elsif referring_member = record_referer(signature, :fb_like_hash, Signature::ReferenceType::FACEBOOK_LIKE)
        petition.experiments.facebook(referring_member).win!(:signature)
      elsif params[:fb_action_id].present?
        facebook_action = Share.find_by_action_id(params[:fb_action_id].to_s)
        referring_member = facebook_action.member
        signature.attributes = {referer: referring_member, reference_type: Signature::ReferenceType::FACEBOOK_SHARE, referring_url: params[:referring_url]}
        petition.experiments.facebook(referring_member).win!(:signature)
      elsif referring_member = record_referer(signature, :fb_share_link_ref, Signature::ReferenceType::FACEBOOK_POPUP)
        petition.experiments.facebook(referring_member).win!(:signature)
      elsif referring_member = record_referer(signature, :fb_dialog_request, Signature::ReferenceType::FACEBOOK_REQUEST)
        petition.experiments.facebook(referring_member).win!(:signature)
      else record_referer signature, :twitter_hash, Signature::ReferenceType::TWITTER end
    end
  end

  def record_referer signature, param_name, reference_type
    if referring_member = Member.find_by_hash(params[param_name])
      signature.attributes = {referer: referring_member, reference_type: reference_type, referring_url: params[:referring_url]}
      referring_member
    end
  end

  def nps_win signature
    if signature.created_member
      win_on_option!("email_scheduler_nps", signature.petition.id.to_s)
      if (signature.reference_type == Signature::ReferenceType::FACEBOOK_LIKE || signature.reference_type == Signature::ReferenceType::FACEBOOK_SHARE || signature.reference_type == Signature::ReferenceType::FACEBOOK_POPUP || signature.reference_type == Signature::ReferenceType::FACEBOOK_REQUEST) 
        win_on_option!("facebook sharing options", signature.reference_type)
      end
    end
  end
end
