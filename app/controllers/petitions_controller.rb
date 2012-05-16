class PetitionsController < ApplicationController
  before_filter :require_login, except: [:show]

  def index
    @petitions = Petition.all
  end

  def show
    @petition = Petition.find(params[:id])
    @sigcount = @petition.signatures.count
    @email_hash = params[:n]
    signed_petitions = session[:signed_petitions] || []
    @user_has_signed = signed_petitions.include? @petition.id
    @signature = Signature.new
    @signature.name = session[:signature_name]
    @signature.email = session[:signature_email]
  end

  def new
    @petition = Petition.new
  end

  def edit
    @petition = Petition.find(params[:id])
    return render_403 unless @petition.has_edit_permissions(current_user)
  end

  def create
    @petition = Petition.new(params[:petition], as: role)
    @petition.owner = current_user

    if @petition.save
      redirect_to @petition, notice: 'Petition was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @petition = Petition.find(params[:id])
    return render_403 unless @petition.has_edit_permissions(current_user)
    if @petition.update_attributes(params[:petition], as: role)
      redirect_to @petition, notice: 'Petition was successfully updated.'
    else
      render action: "edit"
    end
  end
end
