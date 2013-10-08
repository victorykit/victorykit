require 'faraday'
require 'faraday_middleware'

class CRM
  def self.action_kit_connection(config)
    CRM::ActionKit.new(config)
  end
end

class CRM::ActionKit

  def initialize(config)
    @conn = Faraday.new(:url => "https://#{config[:host]}/rest/v1/") do |builder|
      builder.request  :multipart
      builder.response :logger                  # log requests to STDOUT
      builder.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      builder.response :json, :content_type => /\bjson$/
    end
    @conn.basic_auth(config[:user], config[:password])
    self
  end

  def fetch_member_by_email(email)
    Rails.logger.debug "CRM::ActionKit.fetch_member_by_email: #{email}"
    res = @conn.get('user/', {:email => email.downcase})

    if res.body['meta']['total_count'] == 0
      # Not necessarily an error 
      Rails.logger.info "CRM::ActionKit.fetch_member(): AK claims unknown member: #{email}"
      return nil
    elsif res.body['meta']['total_count'] > 1
      # ToDo determine whether this is an error and if so how to handle...
      Rails.logger.error "CRM::ActionKit.fetch_member(): AK claims multiple members: #{email}"
      return false
    end

    ak_member = res.body['objects'][0].symbolize_keys
  end

  def fetch_member_by_location(location)
    Rails.logger.debug "CRM::ActionKit.fetch_member_by_location: #{location}"
    @conn.get(location)
  end

  def fetch_member_by_id(id)
    Rails.logger.debug "CRM::ActionKit.fetch_member_by_id: #{id}"
    fetch_member_by_location("user/#{id}/")
  end

  def fetch_member(data)
    case data
      when Member
        return fetch_member_by_email(data.email)
      when String
        if data.include?('@')
          res = fetch_member_by_email(data)
        else
          res = fetch_member_by_location(data)
        end
      when Fixnum
        res = fetch_member_by_id(data)
      else
        raise "Unknow class: #{data.class}"
    end

    if res.body.blank?
      # ToDo determine what happen and how to handle...
      Rails.logger.warn "CRM::ActionKit.fetch_member(): empty response: #{data}"
      return false
    end

    ak_member = res.body['objects'][0].symbolize_keys
  end

  def create_member(vk_member)
    Rails.logger.debug "CRM::ActionKit.create_member: #{vk_member.email}"

    data = {}
    data[:email]       = vk_member.email.downcase
    data[:first_name]  = vk_member.first_name   if vk_member.first_name.present?
    data[:last_name]   = vk_member.last_name    if vk_member.last_name.present?
    data[:city]        = vk_member.first_name   if vk_member.first_name.present?
    data[:state]       = CRM::States.to_name(vk_member.state_code)      if CRM::States.to_name(vk_member.state_code)
    data[:country]     = CRM::Countries.to_name(vk_member.country_code) if CRM::Countries.to_name(vk_member.country_code)

    res = @conn.post do |req|
      req.url 'user/'
      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end

    if res.status != 201 # CREATED
      raise "CRM::ActionKit.create_member() ERROR: status code: #{res.status}: #{vk_member.email}"
    end

   fetch_member(res.headers['location'])
  end

  def find_or_create_member(vk_member)
    ak_member = fetch_member(vk_member)

    case ak_member
      when Hash
       return ak_member
      when FalseClass    # there was an AK problem...
        return nil
      when NilClass      # AK has no record of the member
        return create_member(vk_member)
      else
        raise "CRM::ActionKit.find_of_create_member(): Bad return value: #{ak_member}"
    end
  end

  def unsub_member(vk_member)
    # Get the crm member id
    # Post the unsub

    Rails.logger.debug "CRM::ActionKit.unsub_member: #{vk_member.email}"

    ak_member = find_or_create_member(vk_member)

    # Deal with AK error at higher level
    return false if ak_member == false

    data = {}
    data[:page]             = 'rootstrikers_unsub'
    data[:email]            = vk_member.email.downcase
    data[:have_unsub_lists] = 1
    data[:unsub_lists]      = AppSettings['crm.default_list']

    res = @conn.post do |req|
      req.url 'action/'
      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end

    if res.status != 201 # CREATED
      raise "CRM::ActionKit.unsub_member() ERROR: status code: #{res.status}: #{vk_member.email}"
    end

    Rails.logger.debug "CRM::ActionKit.unsub_member: Sucess: #{vk_member.email}"

    return true
  end

  def subscribe_member(vk_member)
    # Get the crm member id
    # Post the unsub

    Rails.logger.debug "CRM::ActionKit.subscribe_member: #{vk_member.email}"

    ak_member = find_or_create_member(vk_member)

    # Deal with AK error at higher level
    return false if ak_member == false

    data = {}
    data[:page]    = 'rootstrikers_signup'
    data[:email]   = vk_member.email.downcase

    res = @conn.post do |req|
      req.url 'action/'
      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end

    if res.status != 201 # CREATED
      raise "CRM::ActionKit.subscribe_member() ERROR: status code: #{res.status}: #{vk_member.email}"
    end

    Rails.logger.debug "CRM::ActionKit.subscribe_member: Success: #{vk_member.email}"

    return true
  end

end
