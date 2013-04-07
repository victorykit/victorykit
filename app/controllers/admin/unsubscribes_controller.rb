class Admin::UnsubscribesController < ApplicationController
  newrelic_ignore
  before_filter :require_admin

  def index
    if (from = params[:from].try(:to_date)) && (to = params[:to].try(:to_date))
      send_data Unsubscribe.between(from, to).to_csv,
        :type => 'text/csv; charset=utf-8; header=present', 
        :filename => 'unsubscribes.csv'
    end
  end
end
