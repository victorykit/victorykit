require 'faraday'

class CRM

  @@country_whitelist = @@country_blacklist = nil

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

  def self.country_whitelist
    @@country_whitelist
  end

  def self.country_whitelist=(wl)
    if wl.present?
      @@country_whitelist = wl.split(',').collect{|x| x.strip}
    else
      @@country_whitelist = nil
    end
    @@country_whitelist
  end

  def self.country_blacklist
    @@country_blacklist
  end

  def self.country_blacklist=(bl)
    if bl.present?
      @@country_blacklist = bl.split(',').collect{|x| x.strip}
    else
      @@country_blacklist = nil
    end
    @@country_blacklist
  end

  def self.unsub_member(member)
    connection.unsub_member(member)
  end

  def self.subscribe_member(member)
    connection.subscribe_member(member)
  end

  # returns a CRM::Member
  def self.create_member(member)
    connection.create_member(member)
  end

  # returns a CRM::Member
  def self.find_or_create_member(member)
    connection.find_or_create_member(member)
  end

  # returns a CRM::Member
  def self.find_member_by_email(email)
    connection.fetch_member_by_email(email)
  end

  # returns an array of CRM::Member instances
  def self.new_members_since(timestamp, list)
    connection.new_members_since(timestamp, list)
  end

  # Returns and array of hashes. Each element is the
  # most recent subscription event per member and
  # contains {:email, :action, :timestamp}
  # where action is 'subscribe' or 'unsubscribe'
  def self.subsciption_activity_since(timestamp, list)
    connection.subsciption_activity_since(timestamp, list)
  end


  def self.create_vk_member(crm_mbr)
    vk_mbr = nil
    begin
      # Skip if member's country *is not* whitelisted OR *is* blacklisted
      return nil if country_whitelist && ! (country_whitelist.include?(crm_mbr.country) || country_whitelist.include?(crm_mbr.country_code))
      return nil if country_blacklist &&   (country_blacklist.include?(crm_mbr.country) || country_blacklist.include?(crm_mbr.country_code))

      if crm_mbr.email.present?      &&
         crm_mbr.first_name.present? &&
         crm_mbr.last_name.present?
      then
        vk_mbr = Member.new
        vk_mbr.email        = crm_mbr.email
        vk_mbr.created_at   = crm_mbr.created_at
        vk_mbr.first_name   = crm_mbr.first_name
        vk_mbr.last_name    = crm_mbr.last_name
        vk_mbr.state_code   = crm_mbr.state_code
        vk_mbr.country_code = crm_mbr.country_code
        # vk_mbr.zip        = crm_mbr.zip           # Argh! VK does not save zip/postal code. TODO: FIX!

        vk_mbr.syncing_from_crm = true

        vk_mbr.save!
      end

    rescue => e
      Rails.logger.error "CRM.sync_new_crm_members(): mbr sync failed: #{crm_mbr}"
      Rails.logger.error e.message + "\n" + e.backtrace.join("\n")
    end

    vk_mbr
  end


  def self.sync_new_crm_members(timestamp, list)
    t1 = Time.now
    Rails.logger.info "CRM.sync_new_crm_members(#{timestamp}): start= #{t1}"

    new_mbrs = 0

    crm_members = new_members_since(timestamp, list)

    crm_members.each do |crm_mbr|
      vk_mbr = Member.lookup(crm_mbr.email).first

      if vk_mbr.nil?
        vk_mbr = create_vk_member(crm_mbr)
        new_mbrs += 1 if vk_mbr
      end
    end

    Rails.logger.info "CRM.sync_new_crm_members(#{timestamp}): new= #{new_mbrs}  dur=#{Time.now - t1}  end= #{Time.now}"
  end


  def self.sync_crm_subscription_events(timestamp, list)
    t1 = Time.now
    Rails.logger.info "CRM.sync_crm_subscription_events(#{timestamp}): start= #{t1}"

    new_mbrs = subs = unsubs = 0

    events = subsciption_activity_since(timestamp, list)
    events.each do |e|
      begin
        Member.transaction do
          vk_mbr = Member.lookup(e[:email]).first

          if vk_mbr.nil?
            crm_mbr = find_member_by_email(e[:email])
            vk_mbr = create_vk_member(crm_mbr) if crm_mbr
            new_mbrs += 1 if vk_mbr
          end

          next if vk_mbr.nil?

          # Hackish
          vk_mbr.syncing_from_crm = true

          case e[:action]
            when 'subscribe'
              if vk_mbr.membership.nil?
                Rails.logger.info "CRM.sync_crm_subscription_events(): subscribe: #{e[:email]}"
                ms = Membership.new()
                ms.member = vk_mbr
                ms.created_at = e[:created_at]
                ms.save!
                subs += 1
              end

            when 'unsubscribe'
              if vk_mbr.membership
                Rails.logger.info "CRM.sync_crm_subscription_events(): unsubscribe: #{e[:email]}"
                vk_mbr.membership.destroy
                unsubs += 1
              end

            else
              raise "Unknown action: #{e[:action]}"
          end

        end # Member.transaction

      rescue => e
        Rails.logger.error "CRM.sync_crm_subscription_events(): mbr sync failed"
        Rails.logger.error e.message + "\n" + e.backtrace.join("\n")
      end

    end

    Rails.logger.info "CRM.sync_crm_subscription_events(#{timestamp}): mbrs= #{new_mbrs}   subs= +#{subs}/-#{unsubs}  dur=#{Time.now - t1}  end= #{Time.now}"
  end

end
