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
      test_stats[:arms].sort! { |x,y| x[:name] <=> y[:name] }
      mystats.append test_stats unless test_name.starts_with? "email_scheduler"
    end
    mystats.sort! { |x,y| x[:name] <=> y[:name] }
    mystats
  end
  
  def sent_emails_by_part part
    sent_emails_by_hour = SentEmail.count(:group => "date_part('#{part}', created_at)")
    spins = Hash[sent_emails_by_hour.map{|(k,v)| [k.to_i,v]}]
    signed_emails_by_hour = SentEmail.count(:group => "date_part('#{part}', created_at)", :conditions => ['signature_id is not null'])
    wins = Hash[signed_emails_by_hour.map{|(k,v)| [k.to_i,v]}]
    [spins, wins]
  end
  
  def signatures_by_part part
    q = Signature.count(:group => "date_part('#{part}', signatures.created_at)", :joins => :sent_email)
    Hash[q.map{|(k,v)| [k.to_i,v]}]
  end
  
  def nps_by_day
    members = Hash[Member.count(group: 'date(created_at)').map{|(k,v)| [k.to_date, v.to_f]}]
    sent = Hash[SentEmail.count(group: 'date(created_at)').map{|(k,v)| [k.to_date, v.to_f]}]
    members.default, sent.default = 0, 1
    
    start = Date.new(2012, 05, 16)
    (start..Date.today).collect {|x| members[x]/sent[x] }
  end
  
  def index
    @stats = stats
    @hourlydata1 = sent_emails_by_part 'hour'
    @hourlydata2 = signatures_by_part 'hour'
    @dowdata1 = sent_emails_by_part 'dow'
    @dowdata2 = signatures_by_part 'dow'
    @npsdata = nps_by_day
  end
end
