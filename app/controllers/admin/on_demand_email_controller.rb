class Admin::OnDemandEmailController < ApplicationController
  before_filter :require_admin
  def new
    petition= Petition.find(params[:petition_id])
    member = Member.find(params[:member_id])
    email = ScheduledMailer.new_petition petition, member
    render :text => email.to_s
  end

end
