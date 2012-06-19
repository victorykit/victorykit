require 'whiplash'
class ApplicationController < ActionController::Base
  include Bandit
  helper_method :win!, :spin!, :can
  
  protect_from_forgery
  before_filter :add_environment_to_title

  def add_environment_to_title
    @title = "Watchdog.net"
    @title << " - #{Rails.env}" unless Rails.env.production? 
  end
  
  def connecting_ip
    headers["CF-Connecting-IP"] || request.remote_ip
  end
  
  private
  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
    
  def require_login
	  session['redirect_url'] = request.url
    redirect_to login_path if current_user.nil?
  end
    
  def require_admin
    if current_user.nil?
      redirect_to login_path 
    elsif !(current_user.is_admin || current_user.is_super_user)
      render_403
    end
  end

  def render_403
    render :file => "#{Rails.root}/public/403", :formats => [:html], :status => 403
  end
  
  def can(permission)
    current_user && (current_user.is_super_user || current_user.is_admin)
  end
  
  def role
    if can :admin
      :admin
    else
      :default
    end
  end
end
