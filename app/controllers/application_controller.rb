class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
  
  def authorize
    redirect_to login_path if current_user.nil?
  end
  
  def authorize_super_user
    if(current_user.nil?)
      redirect_to login_path 
    elsif(!current_user.is_super_user && !current_user.is_admin)
      render :text => "You are not authorized to view this page", :status => 403
    end
  end
end
