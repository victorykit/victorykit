class UnsubscribesController < ApplicationController
  
  def create
    @unsubscribe = Unsubscribe.new(params[:unsubscribe])
    @unsubscribe.cause = "unsubscribed"
    @unsubscribe.member = Member.find_by_email(@unsubscribe.email)
    @unsubscribe.ip_address = request.remote_ip
    @unsubscribe.user_agent = request.env["HTTP_USER_AGENT"]
    
    if h = Hasher.validate(params[:email_hash])
      @unsubscribe.sent_email = SentEmail.find_by_id(h)
    end
    if !@unsubscribe.member.nil? && @unsubscribe.save
      Notifications.unsubscribed @unsubscribe
      redirect_to root_url, notice: 'You have successfully unsubscribed.'
    else
      redirect_to new_unsubscribe_url, notice: 'There was a problem when we tried to unsubscribe you.'
    end
  end
  
  def new
    @unsubscribe = Unsubscribe.new
    @email_hash = params[:n]
  end
  
end