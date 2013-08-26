class ApplicationController < ActionController::Base

  include Whiplash
  extend Memoist
  helper_method :win!, :spin!, :spin_if_cool_browser!, :measure!, :is_admin

  protect_from_forgery
  before_filter :add_environment_to_title, :stash_http_referer, :add_contact_url_to_footer

  def stash_http_referer
    session['http_referer'] = request.referer || "none" unless session['http_referer']
  end

  def retrieve_http_referer
    session['http_referer'] == "none" ? nil : session['http_referer']
  end

  def add_environment_to_title
    @title = AppSettings.require_keys!("site.name")
    @title << " - #{Rails.env}" unless Rails.env.production?
  end

  def add_contact_url_to_footer
    @contact_url = contact_path
  end

  def connecting_ip
    request.env["HTTP_CF_CONNECTING_IP"] || request.remote_ip
  end

  def spin_if_cool_browser!(test_name, goal, options=[true, false], mysession=nil)
    return options.first unless browser_is_cool?
    spin!(test_name, goal, options, mysession)
  end

  def streaming_csv_export(export)
    filename = "#{export.name}-#{Time.now.strftime("%Y%m%d")}.csv"

    self.response.headers['Content-Type'] = 'text/csv'
    self.response.headers['Last-Modified'] = Time.now.ctime.to_s
    self.response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
    self.response_body = export.as_csv_stream
  end

  def after_sign_in_path_for(resource)
    sign_in_url = url_for(:action => 'new', :controller => 'sessions', :only_path => false, :protocol => 'http')
    if request.referer == sign_in_url
      super
    else
      stored_location_for(resource) || root_path
    end
  end

  private

  def browser_is_cool?
    browser.firefox? || browser.chrome? || browser.safari?
  end

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
