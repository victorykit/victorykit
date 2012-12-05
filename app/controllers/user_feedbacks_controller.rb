class UserFeedbacksController < ApplicationController
  def new
    @feedback = UserFeedback.new
  end
  
  def create
    @feedback = UserFeedback.new(params[:user_feedback])
    if @feedback.save
      begin
        UserFeedbackMailer.new_message(@feedback)
      rescue => ex
        Rails.logger.error "Failed to send feedback email:\n #{ex.backtrace}:\n #{ex.message}"
      end
      redirect_url = session['redirect_url'] || root_path
      redirect_to redirect_url, notice: "Thank you for contacting us. We'll try to reply soon."
    else
      render "new"
    end
  end
end
