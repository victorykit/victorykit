class Admin::UnsubscribesController < ApplicationController
  newrelic_ignore
  before_filter :require_admin

  def index
    if (from = params[:from].try(:to_date)) && (to = params[:to].try(:to_date))
      respond_to do |format|
        format.csv {
          self.response.headers['Content-Type'] = 'text/csv'
          self.response.headers['Last-Modified'] = Time.now.ctime.to_s
          self.response.headers['Content-Disposition'] = 
            "attachment; unsubscribes.csv"

          self.response_body = Enumerator.new do |y|
            i = 0
            Unsubscribe.between(from, to).find_each do |unsub|
              y << unsub.csv_header.to_csv if i == 0
              y << unsub.csv_values.to_csv
              i += 1
              GC.start if i%500==0
            end
          end
        }
      end
    end
  end
end
