class Admin::UsersController < ApplicationController
  before_filter :require_admin
  
  def index
    @users = User.all
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user],{:as => :admin})
      redirect_to admin_users_url, notice: 'User was successfully updated.'
    else
      render action: "edit"
    end
  end
end

