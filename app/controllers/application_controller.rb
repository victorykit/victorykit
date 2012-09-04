class ApplicationController < ActionController::Base
  include Whiplash
  extend Memoist
  helper_method :win!, :spin!, :spin_if_cool_browser!, :is_admin
  
  protect_from_forgery
  before_filter :add_environment_to_title

  def add_environment_to_title
    @title = "Watchdog.net"
    @title << " - #{Rails.env}" unless Rails.env.production? 
  end
  
  def connecting_ip
    request.env["HTTP_CF_CONNECTING_IP"] || request.remote_ip
  end

  def spin_if_cool_browser!(test_name, goal, options=[true, false], mysession=nil)
    return options.first unless browser_is_cool?
    spin!(test_name, goal, options, mysession)
  end
  
  private

  def browser_is_cool?
    browser.firefox? || browser.chrome? || browser.safari?
  end

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

  # Allow access to slightly non-public info (e.g. app status) providing the token param matches the token env variable (or user is admin/super_user).
  # Check is only enabled if VK_DEBUG_TOKEN env variable set, otherwise permission is assumed (convenience for dev environments).
  def debug_access_permitted?
    ENV['VK_DEBUG_TOKEN'].nil? ? true : (params['debug_token'] == ENV['VK_DEBUG_TOKEN']) || is_admin
  end

end
