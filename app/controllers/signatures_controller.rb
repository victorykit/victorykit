require 'sent_email_hasher'

class SignaturesController < ApplicationController
  def create
    petition = Petition.find(params[:petition_id])
    signature = Signature.new(params[:signature])
    signature.ip_address = request.remote_ip
    signature.user_agent = request.env["HTTP_USER_AGENT"]
    signature.member = Member.find_or_initialize_by_email(email: signature.email, name: signature.name)
    signature.created_member = signature.member.new_record?
    if signature.valid?
      petition.signatures.push signature
      petition.save!
      if signature.created_member
        win_on_option!("email_scheduler_nps", petition.id.to_s)
      end
      if h = SentEmailHasher.validate(params[:email_hash])
        sent_email = SentEmail.find_by_id(h)
        sent_email.signature_id ||= signature.id
        sent_email.email_experiments.each {|e| win_on_option!(e.key, e.choice)}
        sent_email.save!
      end
      session[:signature_name] = signature.name
      session[:signature_email] = signature.email
      cookie = cookies[:signed_petitions] || ""
      signed_petitions = cookie.split "|"
      signed_petitions.push petition.id
      cookies[:signed_petitions] = signed_petitions.join "|"
      win! :signature
      Notifications.signed_petition signature
      redirect_to petition_url(petition)
      
    else
      @petition = petition
      @signature = signature
      @sigcount = @petition.signatures.count
      render :template => "petitions/show"
    end
  end
end
