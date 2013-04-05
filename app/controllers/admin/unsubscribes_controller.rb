class Admin::UnsubscribesController < ApplicationController
  def index
    u = Unsubscribe.paginate(:page => params[:page], :per_page => 100)
    @unsubscribes = u
  end
end
