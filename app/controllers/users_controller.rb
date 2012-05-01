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
    if @user && @user.authenticate(params[:user][:current_password]) && (params[:user][:new_password] == params[:user][:verify_password])
      if @user.update_attributes(:password => params[:user][:new_password])
        redirect_to edit_user_url, notice: 'Password was successfully updated.'
      else
        render action: "edit"
      end
    else
      render action: "edit"
    end
  end
  
end

