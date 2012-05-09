class StatusController < ApplicationController
  def index
    @commit_hash = ENV['COMMIT_HASH']
    @session_id = session[:session_id]
  end
end
