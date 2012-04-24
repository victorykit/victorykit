class SessionsController < ApplicationController
  def new
  end
  
  def create
    session[:user_id] = User.find_by_email(params[:email]).id
    redirect_to root_path
  end
end
