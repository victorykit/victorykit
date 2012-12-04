class UserFeedbacksController < ApplicationController
  def new
    @feedback = UserFeedback.new
  end
  
  def create
    @feedback = UserFeedback.new(params[:user_feedback])
    if @feedback.save
      UserFeedbackMailer.new_message(@feedback)
      redirect_url = session['redirect_url'] || root_path
      redirect_to redirect_url, notice: "Thank you for contacting us. We'll try to reply soon."
    else
      render "new"
    end
  end
end
