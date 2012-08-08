class UnsubscribesController < ApplicationController
  
  def create
    @unsubscribe = Unsubscribe.new(params[:unsubscribe])
    @unsubscribe.cause = "unsubscribed"
    @unsubscribe.member = Member.first(:conditions => [ "lower(email) = ?", @unsubscribe.email.downcase ])

    @unsubscribe.ip_address = connecting_ip
    @unsubscribe.user_agent = request.env["HTTP_USER_AGENT"][0...255]
    
    if h = SentEmailHasher.validate(params[:email_hash])
      @unsubscribe.sent_email = SentEmail.find_by_id(h)
    end
    if @unsubscribe.member && @unsubscribe.save
      nps_lose @unsubscribe.sent_email.petition_id if @unsubscribe.sent_email.present?
      Notifications.unsubscribed @unsubscribe
      redirect_to root_url, notice: 'You have successfully unsubscribed.'
    else
      redirect_to new_unsubscribe_url, notice: "Sorry, unsubscribe didn't work. Are you using the same email address you registered with?"
    end
  end
  
  def new
    @unsubscribe = Unsubscribe.new
    @email_hash = params[:n]
    member = MemberHasher.member_for(@email_hash)
    @email = member.email if member
  end

  private

  def nps_lose petition_id
    lose_on_option!("email_scheduler_nps", petition_id)
  end
  
end
