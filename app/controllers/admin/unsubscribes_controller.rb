class Admin::UnsubscribesController < ApplicationController
  newrelic_ignore
  before_filter :require_admin

  def index
    if (from = params[:from].try(:to_date)) && (to = params[:to].try(:to_date))
      respond_to do |format|
        format.csv {
          export = Queries::UnsubscribesExport.new(from: from, to: to)
          filename = "#{export.name}-#{Time.now.strftime("%Y%m%d")}.csv"

          self.response.headers['Content-Type'] = 'text/csv'
          self.response.headers['Last-Modified'] = Time.now.ctime.to_s
          self.response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
          self.response_body = export.as_csv_stream
        }
      end
    end
  end
end
