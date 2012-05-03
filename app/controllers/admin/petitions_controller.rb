class Admin::PetitionsController < ApplicationController
  def index
    @petition_analytics = PetitionAnalytic.all
    respond_to do |format|
      format.html
      format.json { render json: PetitionsDatatable.new(view_context) }
    end
  end
end
