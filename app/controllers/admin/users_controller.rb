class UsersController < ApplicationController
  before_filter :authorize, except: [:new, :create]
  before_filter :authorize_super_user, except: [:new, :create]
  
  def index
    @users = User.all
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
        redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: "edit"
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url
  end
end

