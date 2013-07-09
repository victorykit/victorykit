class Admin::MembersController < ApplicationController
  newrelic_ignore
  before_filter :require_admin

  def index
    respond_to do |format|
      format.html do
        @members = Member.active.
         paginate(:page => params[:page], :per_page => 50).
         order('created_at DESC')
      end

      format.csv do
        export = Queries::MembersExport.new
        filename = "#{export.name}-#{Time.now.strftime("%Y%m%d")}.csv"

        self.response.headers['Content-Type'] = 'text/csv'
        self.response.headers['Last-Modified'] = Time.now.ctime.to_s
        self.response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
        self.response_body = export.as_csv_stream
      end
    end
  end
end
