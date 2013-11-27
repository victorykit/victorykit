#
# Unsub CRM members via their email address.
# Leverages the CRM classes with additions...
#
require 'crm'

#
# Monkey patch the CRM classes to enable un-subbing
# by email address. Since the CRM module is designed to 
# sync the CRM with VictoryKit's database. An unsub
# in VictoryKit is "pushed" (sync'ed) to the CRM.
# As such, the member must exist in the Vk's database.
# 
# The CRM module intentionally does not support
# making changes to a member in the CRM unless the member
# first exists in VK.
#
# This code breaks that requirement/expectation in
# order to support bulk unsubs in ActionKits when
# all we have is a file containing email addresses.
#
# All because DemandProgress wanted to unsub
# "inactive" members in ActionKit...
#
class CRM
  def CRM.unsub_member_via_email(email)
    CRM.connection.unsub_member_via_email(email)
  end
end

class CRM::ActionKit
  def unsub_member_via_email(email)
    data = {}
    data[:page]             = 'api_demandprogress_unsub'
    data[:email]            = email
    data[:have_unsub_lists] = 1
    data[:unsub_lists]      = 1

    res = @conn.post do |req|
      req.url 'action/'
      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end

    if res.status != 201 # CREATED
      Rails.logger.error "CRM::ActionKit.unsub_member() ERROR: status code: #{res.status}: #{email}"
      raise "CRM::ActionKit.unsub_member() ERROR: status code: #{res.status}: #{email}"
    end

    Rails.logger.debug "CRM::ActionKit.unsub_member: Sucess: #{email}"

    return true
  end
end

emails = 0
unsubs = 0
exceptions = 0

file = open(ARGV[0], mode="r")

file.each_line do |email|
  emails += 1
  begin
    puts "#{emails} \t #{email}"
    CRM.unsub_member_via_email(email)
    unsubs += 1
  rescue => e
    exceptions += 1 
    Rails.logger.error "#{e.message}\n#{e.backtrace.join("\n")}"
    puts "#{e.message}\n#{e.backtrace.join("\n")}"
  end
end

file.close


puts "unsubs= #{unsubs}"
puts "exceptions= #{exceptions}"
