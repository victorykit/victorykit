class Admin::PetitionsController < ApplicationController
  before_filter :authorize
  before_filter :authorize_admin

  def index
    respond_to do |format|
      format.html      
      format.json { render json: PetitionsDatatable.new(view_context) }
    end
  end
end
