class Admin::OnDemandEmailController < ApplicationController

  def new
    petition= Petition.find(params[:petition_id])
    member = Member.find(params[:member_id])
    email = ScheduledEmail.new_petition petition, member
    render :text => email.to_s
  end

end
