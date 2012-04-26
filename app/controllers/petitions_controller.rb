class PetitionsController < ApplicationController
  before_filter :authorize, except: [:show, :index]

  def index
    @petitions = Petition.all
  end

  def show
    @petition = Petition.find(params[:id])
    signed_petitions = session[:signed_petitions] || []
    @user_has_signed = signed_petitions.include? @petition.id
    @signature = Signature.new
  end

  def new
    @petition = Petition.new
  end

  def edit
    return render_403 unless has_edit_permissions
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
  
  def has_edit_permissions
    @petition = Petition.find(params[:id])
    @petition.owner.id == current_user.id || current_user.is_admin || current_user.is_super_user
  end
end
