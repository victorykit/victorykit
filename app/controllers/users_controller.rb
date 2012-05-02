class UsersController < ApplicationController
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_url, notice: "Thank you for signing up!"
    else
      render "new"
    end
  end
  
  def update
    @user = User.find(params[:id])
    if @user && @user.authenticate(params[:user][:current_password]) 
      if params[:user][:new_password].empty? || params[:user][:verify_password].empty? 
        flash.now[:error] = "Please enter a new password and verify password"
        render action: "edit"
      elsif params[:user][:new_password] == params[:user][:verify_password]
        @user.update_attributes(:password => params[:user][:new_password])
        redirect_to edit_user_url, notice: "Password was successfully updated"
      else
        flash.now[:error] = "New password does not match the verified password"
        render action: "edit"
      end
    else
      flash.now[:error] = "Current password is incorrect"
      render action: "edit"
    end
  end
  
end
