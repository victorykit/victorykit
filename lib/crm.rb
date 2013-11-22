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

    config.symbolize_keys!

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

  def self.unsub_member(vk_member)
    connection.unsub_member(vk_member)
  end

  def self.subscribe_member(vk_member)
    connection.subscribe_member(vk_member)
  end

  # returns a CRM::Member
  def self.create_member(vk_member)
    connection.create_member(vk_member)
  end

  # returns a CRM::Member
  def self.find_or_create_member(vk_member)
    connection.find_or_create_member(vk_member)
  end

  # returns a CRM::Member
  def self.find_member_by_email(vk_email)
    connection.fetch_member_by_email(vk_email)
  end

  # returns a CRM::Member
  def self.find_member(s)
    connection.fetch_member(s)
  end

  # returns an array of CRM::Member instances
  def self.new_members_since(list, last_id)
    connection.new_members_since(list, last_id)
  end

  # Returns and array of hashes. Each element is the
  # most recent subscription event per member and
  # contains {:email, :action, :timestamp}
  # where action is 'subscribe' or 'unsubscribe'
  def self.subsciption_activity_since(list, last_id)
    connection.subsciption_activity_since(list, last_id)
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
      else
        Rails.logger.error "CRM.create_vk_member(): missing data: skipping e:#{crm_mbr.email} f:#{crm_mbr.first_name} l:#{crm_mbr.last_name}"
      end

    rescue => e
      Rails.logger.error "CRM.sync_new_crm_members(): mbr sync failed: #{crm_mbr}"
      Rails.logger.error e.message + "\n" + e.backtrace.join("\n")
    end

    vk_mbr
  end


  def self.sync_new_crm_members(list, last_id = nil)
    t1 = Time.now
    Rails.logger.info "CRM.sync_new_crm_members(#{list}, #{last_id}): start= #{t1}"

    new_mbrs = skipped = 0
    max_id = last_id = last_id.to_i

    crm_members = new_members_since(list, last_id)

    crm_members.each do |crm_mbr|
      begin
        max_id = (crm_mbr.id.to_i > max_id ? crm_mbr.id.to_i : max_id)

        vk_mbr = Member.lookup(crm_mbr.email).first

        if vk_mbr.nil?
          vk_mbr = create_vk_member(crm_mbr)
          if vk_mbr
            new_mbrs += 1
          else
            skipped += 1
          end
        end

      rescue => e
        Rails.logger.error "CRM.sync_new_crm_members(#{list}, #{last_id}): mbr sync failed"
        Rails.logger.error e.message + "\n" + e.backtrace.join("\n")
      end

    end

    Rails.logger.info "CRM.sync_new_crm_members(#{list}, #{last_id}): new= #{new_mbrs}  skipped= #{skipped}  end= #{Time.now}  dur=#{Time.now - t1}"

    max_id
  end


  def self.sync_crm_subscription_events(list, last_id = nil)
    t1 = Time.now
    Rails.logger.info "CRM.sync_crm_subscription_events(#{list}, #{last_id}): start= #{t1}"

    new_mbrs = subs = unsubs = 0
    max_id = last_id = last_id.to_i

    events = subsciption_activity_since(list, last_id)
    events.each do |e|
      begin
        Member.transaction do
          max_id = (e[:id].to_i > max_id ? e[:id].to_i : max_id)

          vk_mbr = Member.lookup(e[:email]).first

          if vk_mbr.nil?
            # skip creating a VK member if the AK member is missing required data
            if e[:first_name].blank? || e[:last_name].blank?
              Rails.logger.error "CRM.sync_crm_subscription_events(#{list}, #{last_id}): missing data: skipping e:#{e[:email]} f:#{e[:first_name]} l:#{e[:last_name]}"
              next
            end

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
                Rails.logger.info "CRM.sync_crm_subscription_events(#{list}, #{last_id}): subscribe: #{e[:email]}"
                ms = Membership.new()
                ms.member = vk_mbr
                ms.created_at = e[:created_at]
                ms.save!
                subs += 1
              end

            when 'unsubscribe'
              if vk_mbr.membership
                Rails.logger.info "CRM.sync_crm_subscription_events(#{list}, #{last_id}): unsubscribe: #{e[:email]}"
                vk_mbr.membership.destroy
                unsubs += 1
              end

            else
              raise "Unknown action: #{e[:action]}"
          end

        end # Member.transaction

      rescue => e
        Rails.logger.error "CRM.sync_crm_subscription_events(#{list}, #{last_id}): mbr sync failed"
        Rails.logger.error e.message + "\n" + e.backtrace.join("\n")
      end

    end

    Rails.logger.info "CRM.sync_crm_subscription_events(#{list}, #{last_id}): mbrs= #{new_mbrs}   subs= +#{subs}/-#{unsubs}  end= #{Time.now}  dur=#{Time.now - t1}"

    max_id
  end

end
