class UsersController < ApplicationController
  before_filter :require_login, except: [:new, :create]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_url = session['redirect_url'] || root_path
      redirect_to redirect_url, notice: "Thank you for signing up!"
    else
      render "new"
    end
  end
  
  def update
    @user = current_user
    if @user.update_with_password(params[:user])
      flash.notice = "Password was successfully updated."
      sign_in @user, :bypass => true
      redirect_to root_url
    else
      render action: "edit"
    end
  end
end
