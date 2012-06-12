class Admin::ExperimentsController < ApplicationController
  newrelic_ignore
  before_filter :require_admin
  
  # @@FIX:
  # This should all really be in whiplash, but I can't figure out how to call it properly.
  def all_tests
    tests = {}
    REDIS.keys('whiplash/goals/*').each do |g|
      REDIS.smembers(g).each do |t|
        tests[t] = {goal: g[15..-1], options: []}
      end
    end
    
    tests.keys.each do |t|
      prefix = "whiplash/#{t}/"
      suffix = "/spins"
      REDIS.keys(prefix + "*" + suffix).each do |o|
        tests[t][:options].append o[prefix.length..-suffix.length-1]
      end
    end
    tests
  end
  
  def stats
    mystats = []
    all_tests.each do |test_name, test_info|
      test_stats = {
        name: test_name,
        trials: 0,
        arms: [],
        goal: test_info[:goal]
      }
      test_info[:options].each do |opt_name|
        spins = REDIS.get("whiplash/#{test_name}/#{opt_name}/spins").to_i
        test_stats[:arms].append({
          name: opt_name,
          spins: spins,
          wins: REDIS.get("whiplash/#{test_name}/#{opt_name}/wins").to_i,
        })
        test_stats[:trials] += spins
      end
      mystats.append test_stats unless test_name.starts_with? "email_scheduler"
    end
    mystats
  end
  
  def sent_emails_by_hour
	  sent_emails_by_hour = SentEmail.count(:group => "date_part('hour', created_at)")
    spins = Hash[sent_emails_by_hour.map{|(k,v)| [k.to_i,v]}]
	  signed_emails_by_hour = SentEmail.count(:group => "date_part('hour', created_at)", :conditions => ['signature_id is not null'])
    wins = Hash[signed_emails_by_hour.map{|(k,v)| [k.to_i,v]}]
    [spins, wins]
  end

  def index
    @stats = stats
    @hourlydata = sent_emails_by_hour
  end
end
