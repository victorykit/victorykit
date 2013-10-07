require 'faraday'

class CRM

  def self.connection(config = nil)

    if config.nil?
      config = Hash.new
      config[:provider] = AppSettings['crm.provider'] 
      config[:host]     = AppSettings['crm.host'] 
      config[:user]     = AppSettings['crm.user'] 
      config[:password] = AppSettings['crm.password'] 
    end

    config = config.symbolize_keys

    begin
      require "crm/#{config[:provider]}"
    rescue LoadError => e
      raise LoadError, "Bad CRM: #{config[:provider]}", e.backtrace
    end

    provider_method = "#{config[:provider]}_connection"

    CRM.send(provider_method, config)
  end

  def self.unsub_member(member)
    connection.unsub_member(member)
  end

  def self.subscribe_member(member)
    connection.subscribe_member(member)
  end

  def self.create_member(member)
    connection.create_member(member)
  end

  def self.find_or_create_member(member)
    connection.find_or_create_member(member)
  end

  def self.find_member_by_email(email)
    connection.fetch_member_by_email(email)
  end

end
