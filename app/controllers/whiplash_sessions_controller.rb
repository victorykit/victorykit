class WhiplashSessionsController < ApplicationController

  newrelic_ignore
  
  def index
    @keys = REDIS.keys('whiplash/*/*/spins').map {|key| key.sub('whiplash/','').sub(/\/.+/,'')}.uniq
    respond_to do |format|
      format.html {
        @commit_hash = ENV['COMMIT_HASH']
        @session_id = request.session_options[:id]
        @user_agent = request.env['HTTP_USER_AGENT']
        @can_update_session = can_update_session?
        @debug_token = params[:debug_token] }
      format.json {
        render json: @keys }
    end
  end

  def create
    if can_update_session?
      params.each do |k, v|
        session[k] = convert_type(v)
      end
      session["manual_whiplash_mode"] = true
    end
    redirect_to action: 'index', debug_token: params[:debug_token]
  end

  private
  def convert_type string
    return true if(string == "true")
    return false if(string == "false")
    Integer(string) if Integer(string) rescue string
  end

  def can_update_session?
    debug_token_provided?
  end
end
