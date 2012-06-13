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
    boolean_converter = ->(s){ s == "true" ? true : false}
    type_converters = {
      Fixnum => ->(s){s.to_i},
      Float => ->(s){s.to_f},
      Date => ->(s){s.to_date},
      TrueClass => boolean_converter,
      FalseClass => boolean_converter, String => ->(s){s}
    }
    tc = type_converters[clazz]
    raise "Conversion not yet specified for class: '#{clazz}'" if not tc
    tc[value]
  end

  def can_update_session?
    return (params['debug_token'] == ENV['VK_DEBUG_TOKEN'])
  end

end
