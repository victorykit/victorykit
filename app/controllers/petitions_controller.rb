class PetitionsController < ApplicationController
  # GET /petitions
  # GET /petitions.json
  def index
    @petitions = Petition.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @petitions }
    end
  end

  # GET /petitions/1
  # GET /petitions/1.json
  def show
    @petition = Petition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @petition }
    end
  end

  # GET /petitions/new
  # GET /petitions/new.json
  def new
    @petition = Petition.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @petition }
    end
  end

  # GET /petitions/1/edit
  def edit
    @petition = Petition.find(params[:id])
  end

  # POST /petitions
  # POST /petitions.json
  def create
    @petition = Petition.new(params[:petition])

    respond_to do |format|
      if @petition.save
        format.html { redirect_to @petition, notice: 'Petition was successfully created.' }
        format.json { render json: @petition, status: :created, location: @petition }
      else
        format.html { render action: "new" }
        format.json { render json: @petition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /petitions/1
  # PUT /petitions/1.json
  def update
    @petition = Petition.find(params[:id])

    respond_to do |format|
      if @petition.update_attributes(params[:petition])
        format.html { redirect_to @petition, notice: 'Petition was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @petition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /petitions/1
  # DELETE /petitions/1.json
  def destroy
    @petition = Petition.find(params[:id])
    @petition.destroy

    respond_to do |format|
      format.html { redirect_to petitions_url }
      format.json { head :no_content }
    end
  end
end
