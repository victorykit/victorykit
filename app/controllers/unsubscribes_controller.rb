class UnsubscribesController < ApplicationController
  
  def create
    @unsubscribe = Unsubscribe.new(params[:unsubscribe])
    @unsubscribe.cause = "unsubscribed"
    @unsubscribe.member = Member.find_by_email(@unsubscribe.email)
    
    if !@unsubscribe.member.nil? && @unsubscribe.save
      redirect_to root_url, notice: 'You have successfully unsubscribed.'
    else
      render action: "new"
    end
  end
  
  def new
    @unsubscribe = Unsubscribe.new
  end
  
end