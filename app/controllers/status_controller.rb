class StatusController < ApplicationController
  def index
    @commit_hash = ENV['COMMIT_HASH']
    session[:tmp] = 1
    session.delete(:tmp)
    @session_id = request.session_options[:id]
    @user_agent = request.env['HTTP_USER_AGENT']

    @can_update_session = can_update_session?

    if @can_update_session
      params.each do |p|
        key = p[0].gsub('__', ' ')
        if session[key] then session[key] = p[1] end
      end
    end
  end

  def can_update_session?
    return (params['debug_token'] == ENV['VK_DEBUG_TOKEN'])
  end
end
