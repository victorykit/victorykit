class UnsubscribesController < ApplicationController
  
  def create
    @unsubscribe = Unsubscribe.new(params[:unsubscribe])
    @unsubscribe.cause = "unsubscribed"
    @unsubscribe.member = Member.first(:conditions => [ "lower(email) = ?", @unsubscribe.email.downcase ])

    @unsubscribe.ip_address = connecting_ip
    @unsubscribe.user_agent = request.env["HTTP_USER_AGENT"].try(:truncate, 255, omission: "")
    
    if email = ScheduledEmail.find_by_hash(params[:email_hash])
      @unsubscribe.sent_email = email
    end
    
    if @unsubscribe.member && @unsubscribe.save
      nps_lose @unsubscribe.sent_email.petition_id if @unsubscribe.sent_email.present?
      win_for_unsubscribe_email_experiment @unsubscribe.sent_email.id if @unsubscribe.sent_email.present?
      Notifications.unsubscribed @unsubscribe
      redirect_to root_url, notice: 'You have successfully unsubscribed.'
    else
      redirect_to new_unsubscribe_url, notice: "Sorry, unsubscribe didn't work. Are you using the same email address you registered with?"
    end
  end
  
  def new
    @unsubscribe = Unsubscribe.new
    @email_hash = params[:n]
    sent_email = ScheduledEmail.find_by_hash(@email_hash)
    @email = sent_email.email if sent_email
  end

  private

  def nps_lose petition_id
    lose_on_option!("email_scheduler_nps", petition_id)
  end

  def win_for_unsubscribe_email_experiment sent_email_id
    e = EmailExperiment.find_by_sent_email_id_and_goal_and_key(sent_email_id, :unsubscribe, "show less prominent unsubscribe link")
    # The line below is monkey-patch code, so that the loser (which causes less unsubscribes) gets picked more often
    win_on_option!("show less prominent unsubscribe link", e.choice == 't' ? false : true) if e.present?
  end
  
end
