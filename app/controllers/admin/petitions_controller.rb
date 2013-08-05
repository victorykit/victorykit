class Admin::PetitionsController < ApplicationController
  before_filter :require_admin

  def index
    params[:time_span] ||= 'month'
    respond_to do |format|
      format.html {}
      format.json { render json: PetitionsDatatable.new(view_context, PetitionReportRepository.new) }
    end
  end
end
