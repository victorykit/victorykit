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
        if session.has_key?(key) then
          session[key] = convert_type(p[1], session[key].class)
        end
      end
    end
  end

  def convert_type(value, clazz)
    if clazz == FalseClass || clazz == TrueClass
      return false if value == "false"
      return true if value == "true"
    end

    return value.to_i if clazz == Fixnum
    return value if clazz == String
    raise "Conversion not yet specified for class: '#{clazz}'"
  end

  def can_update_session?
    return (params['debug_token'] == ENV['VK_DEBUG_TOKEN'])
  end
end
