class Admin::UnsubscribesController < ApplicationController
  newrelic_ignore
  before_filter :require_admin

  def index
    @unsubscribes = Unsubscribe.paginate(:page => params[:page], :per_page => 100)
  end
end
