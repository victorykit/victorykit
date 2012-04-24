class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = User.find_by_email(params[:email]).id
      redirect_to root_path
    else
      flash.now[:error] = "Invalid username or password"
      render :new
    end
  end
  
  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out!"
  end
end
