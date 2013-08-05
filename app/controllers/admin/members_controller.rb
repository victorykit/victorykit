class Admin::MembersController < ApplicationController
  before_filter :require_admin

  def index
    respond_to do |format|
      format.html do
        @members = Member.active.
         paginate(:page => params[:page], :per_page => 50).
         order('created_at DESC')
      end

      format.csv do
        streaming_csv_export Queries::MembersExport.new
      end
    end
  end
end
