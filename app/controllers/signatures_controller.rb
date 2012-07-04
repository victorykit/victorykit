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

        record_email_reference(params[:email_hash], signature)
        record_shared_link_reference(params[:referer_hash], signature)
        record_facebook_like_reference(params[:fb_hash], signature)
        record_facebook_share_reference(params[:fb_action_id], signature)
        nps_win signature

        cookies[:member_id] = {:value => MemberHasher.generate(signature.member_id), :expires => 100.years.from_now}
        
        flash[:signature_id] = signature.id

        win! :signature
      rescue => ex
        flash.notice = ex.message
      end
    else
      flash[:invalid_signature] = signature
    end
    redirect_to petition_url(petition)
  end

  private

  def record_email_reference hash, signature
    if h = SentEmailHasher.validate(hash)
      begin
        # update sent email table
        sent_email = SentEmail.find_by_id(h)
        sent_email.signature ||= signature
        sent_email.email_experiments.each {|e| win_on_option!(e.key, e.choice)}
        sent_email.save!
        # update reference in signature table
        signature.reference_type = Signature::ReferenceType::EMAIL
        signature.referer = sent_email.member
        signature.save!
      rescue => er
        Rails.logger.error "Error in recording email reference: #{er} #{er.backtrace.join}"
      end
    end
  end

  def record_shared_link_reference hash, signature
    if h = MemberHasher.validate(hash)
      begin
        signature.reference_type = Signature::ReferenceType::SHARED_LINK
        signature.referer = Member.find(h)
        signature.save!
      rescue => er
        Rails.logger.error "Error in recording shared link reference: #{er} #{er.backtrace.join}"
      end
    end
  end

  def record_facebook_like_reference hash, signature
    if h = MemberHasher.validate(hash)
      begin
        referer = Member.find(h)
        signature.reference_type = Signature::ReferenceType::FACEBOOK_LIKE
        signature.referer = referer
        signature.save!
      rescue => er
        Rails.logger.error "Error in recording facebook like reference: #{er} #{er.backtrace.join}"
      end
    end
  end

  def record_facebook_share_reference action_id, signature
    if action_id.present?
      begin
        facebook_action = FacebookAction.find_by_action_id(action_id.to_s)
        referer = facebook_action.member
        signature.reference_type = Signature::ReferenceType::FACEBOOK_SHARE
        signature.referer = referer
        signature.save!
      rescue => er
        Rails.logger.error "Error in recording facebook share reference: #{er} #{er.backtrace.join}"
      end
    end
  end

  def nps_win signature
    if signature.created_member
      win_on_option!("email_scheduler_nps", signature.petition.id.to_s)
      win_on_option!("facebook_nps", signature.reference_type) if signature.reference_type.present?
    end
  end
end
