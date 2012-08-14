require 'whiplash'

class ApplicationController < ActionController::Base
  include Bandit
  extend Memoist
  helper_method :win!, :spin!, :is_admin
  
  protect_from_forgery
  before_filter :add_environment_to_title

  def add_environment_to_title
    @title = "Watchdog.net"
    @title << " - #{Rails.env}" unless Rails.env.production? 
  end
  
  def connecting_ip
    request.env["HTTP_CF_CONNECTING_IP"] || request.remote_ip
  end
  
  private
  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
  
  def require_login
    if current_user.nil?
      session['redirect_url'] = request.url
      redirect_to login_path
    end
  end
    
  def require_admin
    if current_user.nil? #@@ is there some way to DRY this with the function above?
      session['redirect_url'] = request.url
      redirect_to login_path
    elsif !(current_user.is_admin || current_user.is_super_user)
      render_403
    end
  end

  def render_403
    render :file => "#{Rails.root}/public/403", :formats => [:html], :status => 403
  end
  
  def is_admin
    current_user && (current_user.is_super_user || current_user.is_admin)
  end
  
  def role
    is_admin ? :admin : :default
  end

  def debug_token_provided?
    if ENV['VK_DEBUG_TOKEN'].nil?
      #need it to make debug_token verification work properly on environments without VK_DEBUG_TOKEN set
      true
    else
      (params['debug_token'] == ENV['VK_DEBUG_TOKEN'])
    end
  end

end
