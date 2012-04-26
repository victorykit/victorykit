class PetitionsController < ApplicationController
  before_filter :authorize, except: [:show, :index]
  before_filter :authorize_super_user, only: [:edit, :update]

  def index
    @petitions = Petition.all
  end

  def show
    @petition = Petition.find(params[:id])
    signed_petitions = session[:signed_petitions] || []
    @user_has_signed = signed_petitions.include? @petition.id
  end

  def new
    @petition = Petition.new
  end

  def edit
    @petition = Petition.find(params[:id])
  end

  def create
    @petition = Petition.new(params[:petition])
    @petition.owner = current_user

    if @petition.save
      redirect_to @petition, notice: 'Petition was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @petition = Petition.find(params[:id])
    if @petition.update_attributes(params[:petition])
      redirect_to @petition, notice: 'Petition was successfully updated.'
    else
      render action: "edit"
    end
  end
end
