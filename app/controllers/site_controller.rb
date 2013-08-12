class SiteController < ApplicationController

  def index
    if current_user.present?
      redirect_to admin_dashboard_path
    else
      redirect_to login_path
    end
  end

end
