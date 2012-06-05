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
      mystats.append test_stats
    end
    mystats
  end
  
  def sent_emails_by_hour
    sent_emails_by_hour = ActiveRecord::Base.connection.execute("select count(id) as sent, date_part('hour', created_at) as hour from sent_emails group by hour")
    spins = sent_emails_by_hour.inject({}) {|h, r| h[r["hour"].to_i] = r["sent"].to_i; h}
    signed_emails_by_hour = ActiveRecord::Base.connection.execute("select count(id) as signed, date_part('hour', created_at) as hour from sent_emails where signature_id is not null group by hour")
    wins = signed_emails_by_hour.inject({}) {|h, r| h[r["hour"].to_i] = r["signed"].to_i; h}
    [spins, wins]
  end

  def index
    @stats = stats
    @hourlydata = sent_emails_by_hour
  end
end
