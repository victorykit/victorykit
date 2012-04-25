class UsersController < ApplicationController
  before_filter :authorize, except: [:new, :create]
  before_filter :authorize_super_user, except: [:new, :create]
  
  def index
    @users = User.all

    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end
  
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def create
    @user = User.new(params[:user])
    @user.is_super_user = false
    if @user.save
      redirect_to root_url, notice: "Thank you for signing up!"
    else
      render "new"
    end
  end
end

