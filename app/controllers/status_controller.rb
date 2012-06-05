class StatusController < ApplicationController
  def index
    @commit_hash = ENV['COMMIT_HASH']
    session[:tmp] = 1
    session.delete(:tmp)
    @session_id = request.session_options[:id]
	  @user_agent = request.env['HTTP_USER_AGENT']
  end
end
