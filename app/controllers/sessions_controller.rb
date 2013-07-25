class SessionsController < ApplicationController
  def create
    user = User.find_by_email(params[:new_session][:email])
    if user && user.authenticate(params[:new_session][:password])
      session[:user_id] = user.id
      redirect_to session['redirect_url'] || admin_dashboard_path
    else
      flash[:error] = "Invalid username or password"
      redirect_to login_path
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out!"
  end
end
