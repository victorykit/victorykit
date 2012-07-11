class WhiplashSessionsController < ApplicationController
  def index
    @keys = REDIS.keys('whiplash/*/*/spins').map {|key| key.sub('whiplash/','').sub(/\/.+/,'')}.uniq
    @commit_hash = ENV['COMMIT_HASH']
    @session_id = request.session_options[:id]
    @user_agent = request.env['HTTP_USER_AGENT']
    @can_update_session = can_update_session?
    @debug_token = params[:debug_token]
  end

  def create
    if can_update_session?
      params.each do |k, v|
        session[k] = convert_type(v)
      end
    end
    redirect_to action: 'index', debug_token: params[:debug_token]
  end

  private
  def convert_type string
    if(string == "true")
      return true
    end
    if(string == "false")
      return false
    end
    Integer(string) if Integer(string) rescue string
  end

  def can_update_session?
    if ENV['VK_DEBUG_TOKEN'].nil?
      #need it to make debug_token verification work properly on environments without VK_DEBUG_TOKEN set
      true
    else
      (params['debug_token'] == ENV['VK_DEBUG_TOKEN'])
    end
  end
end
