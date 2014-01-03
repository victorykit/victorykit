require 'faraday'
require 'faraday_middleware'

class CRM
  def self.action_kit_connection(config)
    CRM::ActionKit.new(config)
  end
end

class CRM::ActionKit

  require 'mysql2'

  private

  MAX_RECORDS = 500

  def initialize(config)
    @conn = Faraday.new(:url => "https://#{config[:host]}/rest/v1/") do |builder|
      builder.request  :multipart
      builder.response :logger, Logger.new("#{Rails.root}/log/crm_faraday.log")
      builder.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      builder.response :json, :content_type => /\bjson$/
    end
    @conn.basic_auth(config[:user], config[:password])

    self
  end

  def ak_db_config
    Settings.action_kit.to_hash
  end

  def ak_db_conn
    @db_conn if @db_conn

    @db_conn = Mysql2::Client.new(ak_db_config)

    # The queries executed are mildly nasty, so give then some room to run.
    @db_conn.query('SET SESSION join_buffer_size = 1024 * 1024 * 1024')
    @db_conn.query('SET SESSION sort_buffer_size = 1024 * 1024 * 1024')
    @db_conn.query('SET SESSION SQL_BIG_SELECTS = 1')

    @db_conn
  end

  public

  def fetch_member_by_email(email)
    Rails.logger.debug "CRM::ActionKit.fetch_member_by_email: #{email}"
    res = @conn.get('user/', {:email => email})

    if res.body['meta']['total_count'] == 0
      # Not necessarily an error
      Rails.logger.info "CRM::ActionKit.fetch_member(): AK claims unknown member: #{email}"
      return nil
    elsif res.body['meta']['total_count'] > 1
      # ToDo determine whether this is an error and if so how to handle...
      Rails.logger.error "CRM::ActionKit.fetch_member(): AK claims multiple members: #{email}"
      return false
    end

    # res.body['objects'][0].symbolize_keys
    CrmMember.new(res.body['objects'][0])
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
          return fetch_member_by_email(data)
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

    CrmMember.new(res.body)
  end

  def create_member(vk_member)
    Rails.logger.debug "CRM::ActionKit.create_member: #{vk_member.email}"

    data = {}
    data[:email]       = vk_member.email
    data[:first_name]  = vk_member.first_name   if vk_member.first_name.present?
    data[:last_name]   = vk_member.last_name    if vk_member.last_name.present?

    # Grrr... VK doesn't capture city or zip code.
    # data[:city]        = vk_member.city         if vk_member.city.present?

    data[:state]       = CRM::States.to_name(vk_member.state_code)      if CRM::States.to_name(vk_member.state_code)
    data[:country]     = CRM::Countries.to_name(vk_member.country_code) if CRM::Countries.to_name(vk_member.country_code)

    res = @conn.post do |req|
      req.url 'user/'
      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end

    case res.status
      when 201 # Created
        return fetch_member(res.headers['location'])
      when 409 # Exists
        return fetch_member(vk_member)
      else
        raise "CRM::ActionKit.create_member() ERROR: status code: #{res.status}: #{vk_member.email}"
    end

  end


  def find_or_create_member(vk_member)
    ak_member = fetch_member(vk_member)

    case ak_member
      when CrmMember
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
    data[:page]             = AppSettings['ak_unsub_page']   # The page determines the AK list
    data[:email]            = vk_member.email
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
    data[:page]  = AppSettings['ak_signup_page']   # The page determines the AK list
    data[:email] = vk_member.email

    res = @conn.post do |req|
      req.url 'action/'
      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end

    if res.status != 201 # CREATED
      raise "CRM::ActionKit.subscribe_member() ERROR: status code: #{res.status}: #{vk_member.email}\n#{res.body}"
    end

    Rails.logger.debug "CRM::ActionKit.subscribe_member: Success: #{vk_member.email}"

    return true
  end


  def new_members_since(list, last_id)
    Rails.logger.debug "CRM::ActionKit.new_members_since(): list= #{list}  last_id= #{last_id}"

    begin
      sql = <<-SQL
        SELECT cu.*
          FROM core_user cu, core_subscription cs
         WHERE cu.id > #{last_id}
           AND cu.id = cs.user_id
           AND cs.list_id IN (#{list})
#           AND (cu.first_name IS NOT NULL AND length(cu.first_name) > 0 AND cu.last_name is NOT NULL AND length(cu.last_name) > 0)
         ORDER BY cu.id
         LIMIT #{MAX_RECORDS}
      SQL

      crm_members = []

      results = ak_db_conn.query(sql)

      results.each do |r|
        data = {}
        data[:id]          = r['id'].to_i
        data[:email]       = r['email']
        data[:created_at]  = r['created_at']
        data[:first_name]  = r['first_name']
        data[:last_name]   = r['last_name']
        data[:postal_code] = r['postal'] if r['postal'].present?

        r['state'].strip!
        r['country'].strip!

        # Some of the data in ActionKit is dodgy including many
        # instances of country being "'United" (note the leading
        # single-quote) when 'United States" was intended.
        if r['country'].index('United') == 1 && (CRM::States.to_code(r['state']) || CRM::States.to_name(r['state']))
          r['country'] = 'United States'
        end

        # ActionKit generally stores full country and state names.
        # Extra bs is required because data in AK is not consistent. Sigh...
        if r['country'].present?
          if r['country'].size == 2 && CRM::Countries.to_name(r['country'])
            data[:country] = CRM::Countries.to_name(r['country'])
            data[:country_code] = r['country']
          else
            data[:country] = r['country]']
            data[:country_code] = (CRM::Countries.to_code(r['country']) ? CRM::Countries.to_code(r['country']) : nil)
          end
        end

        if r['state'].present?
          if r['state'].size == 2 && CRM::States.to_name(r['state'])
            data[:state] = CRM::States.to_name(r['state'])
            data[:state_code] = r['state']
          else
            data[:state] = r['state]']
            data[:state_code] = (CRM::States.to_code(r['state']) ? CRM::States.to_code(r['state']) : nil)
          end
        end

        crm_members << CrmMember.new(data)
      end

    rescue => e
      Rails.logger.error e.message + "\n\tlist= #{list}  last_id= #{last_id}\n" + e.backtrace.join("\n")
    end

    Rails.logger.debug "CRM::ActionKit.new_members_since: Success: list= #{list}  last_id= #{last_id}"

    crm_members
  end


  def subsciption_activity_since(list, last_id)
    Rails.logger.debug "CRM::ActionKit.subsciption_activity_since(): list= #{list}  last_id= #{last_id}"

    begin
      # For subscription events since the last_id,
      # retrieve the most recent event for each user.
      sql = <<-SQL
        SELECT csh.id, csh.created_at,
               cu.email, cu.first_name, cu.last_name,
               CASE WHEN LOCATE('unsubscribe', cshct.name) = 1 THEN 'unsubscribe' ELSE 'subscribe' END AS action
          FROM core_user cu,
               core_subscriptionchangetype cshct,
               core_subscriptionhistory csh
               JOIN
               (
                 SELECT MAX(id) max_id, user_id
                   FROM core_subscriptionhistory cshx2
                  WHERE cshx2.id > #{last_id}
                  GROUP by cshx2.user_id
               ) AS users ON csh.id = users.max_id
         WHERE csh.user_id = cu.id
           AND csh.change_id = cshct.id
           AND csh.list_id IN (#{list})
           AND csh.id > #{last_id}
           AND (cu.first_name IS NOT NULL AND length(cu.first_name) > 0 AND cu.last_name is NOT NULL AND length(cu.last_name) > 0)
         ORDER BY csh.id
         LIMIT #{MAX_RECORDS}
      SQL

      results = ak_db_conn.query(sql, :symbolize_keys => true)

    rescue => e
      Rails.logger.error e.message + "\n\tlist= #{list}  last_id= #{last_id}\n" + e.backtrace.join("\n")
    end

    Rails.logger.debug "CRM::ActionKit.subsciption_activity_since(): Success: list= #{list}  last_id= #{last_id}"

    results.to_a
  end

end
