require 'sent_email_hasher'
require 'member_hasher'

class SignaturesController < ApplicationController
  def create
    petition = Petition.find(params[:petition_id])
    signature = Signature.new(params[:signature])
    signature.ip_address = connecting_ip
    signature.user_agent = request.env["HTTP_USER_AGENT"]
    signature.member = Member.find_or_initialize_by_email(email: signature.email, name: signature.name)
    signature.created_member = signature.member.new_record?
    if signature.valid?
      begin
        petition.signatures.push signature
        Notifications.signed_petition signature
        petition.save!

        track_referals signature, params
        signature.save!
        nps_win signature
        win! :signature

        cookies[:member_id] = {:value => MemberHasher.generate(signature.member_id), :expires => 100.years.from_now}
        flash[:signature_id] = signature.id
      rescue => ex
        Rails.logger.error "Error saving signature: #{ex} #{ex.backtrace.join}"
        flash.notice = ex.message
      end
    else
      flash[:invalid_signature] = signature
    end
    redirect_to petition_url(petition)
  end

  private

  def track_referals signature, params
    if h = SentEmailHasher.validate(params[:email_hash])
      sent_email = SentEmail.find_by_id(h)
      sent_email.signature ||= signature
      sent_email.email_experiments.each {|e| win_on_option!(e.key, e.choice)}
      sent_email.save!
      signature.attributes = {referer: sent_email.member, reference_type: Signature::ReferenceType::EMAIL}
    end
    referring_url = params[:referring_url]
    if h = MemberHasher.validate(params[:referer_hash])
      signature.attributes = {referer: Member.find(h), reference_type: Signature::ReferenceType::SHARED_LINK, referring_url: referring_url}
    end
    if h = MemberHasher.validate(params[:fb_hash])
      signature.attributes = {referer: Member.find(h), reference_type: Signature::ReferenceType::FACEBOOK_LIKE, referring_url: referring_url}
    end
    if h = MemberHasher.validate(params[:twitter_hash])
      signature.attributes = {referer: Member.find(h), reference_type: Signature::ReferenceType::TWITTER, referring_url: referring_url}
    end
    if params[:fb_action_id].present?
      facebook_action = FacebookAction.find_by_action_id(action_id.to_s)
      signature.attributes = {referer: facebook_action.member, reference_type: Signature::ReferenceType::FACEBOOK_SHARE, referring_url: referring_url}
    end
  end

  def nps_win signature
    if signature.created_member
      win_on_option!("email_scheduler_nps", signature.petition.id.to_s)
      win_on_option!("facebook_nps", signature.reference_type) if signature.reference_type.present?
    end
  end
end