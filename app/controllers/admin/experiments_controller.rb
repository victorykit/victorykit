require 'application_metrics'
class Admin::ExperimentsController < ApplicationController
  include ApplicationMetrics
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
    sent = Hash[SentEmail.count(group: 'date(created_at)').map {|(k,v)| [k.to_date, v.to_f]}]
    sent.default = 1
    
    chart_for_table = Proc.new do |table, conditions=nil, subtract_unsubs=false|
      prefs = {group: 'date(created_at)', conditions: conditions}
      out = Hash[table.count(prefs).map {|(k,v)| [k.to_date, v.to_f]}]
      out.default = 0
      if subtract_unsubs
        #NOTE: This does not include resubscribes, but there aren't many of those.
        unsubs = Hash[Unsubscribe.count(prefs).map {|(k,v)| [k.to_date, v.to_f]}]
        unsubs.default = 0
      end
      (Date.new(2012, 05, 16)..Date.today).collect do |x| 
        n = out[x]
        n -= unsubs[x] if subtract_unsubs
        n/sent[x]
      end
    end
    
    #chart_for_table.call SentEmail, 'opened_at is not null'
    #chart_for_table.call SentEmail, 'clicked_at is not null'
    #chart_for_table.call SentEmail, 'signature_id is not null'
    #chart_for_table.call Signature, 'referer_id != member_id'
    #chart_for_table.call Signature, "user_agent like '%MSIE%'"    
    #chart_for_table.call Signature
    #chart_for_table.call Signature, 'created_member is not true'
    
    chart_for_table.call Member, nil, true
  end
    
  def index
    @stats = stats
    @filter = params[:f]
    @options = ["experiments", "petitions", "both", "metrics", "browser statistics"]
    
    case @filter
    when "petitions"
      @stats = @stats.select{|x| x[:name].match /^petition \d+/}.reverse
    when "both"
    when "browser statistics"
      signature_count = Signature.count
      results = Signature.count(:group => "browser_name", :order => "count_all desc")
      @browser_stat = Hash[results.map {|k,v| [k, "%2.2f" % [v.to_f*100/signature_count]]}]
    when "metrics"
      @hourlydata1 = sent_emails_by_part 'hour'
      @hourlydata2 = signatures_by_part 'hour'
      @dowdata1 = sent_emails_by_part 'dow'
      @dowdata2 = signatures_by_part 'dow'
      @npsdata = nps_by_day
      @opened_emails_percentage = opened_emails_percentage
      @clicked_email_links_percentage = clicked_email_links_percentage
    else "experiments"
      @filter = "experiments"
      @stats = @stats.select{|x| !x[:name].match /^petition \d+/}
    end

  end

  def daily_browser_stats
    results = Signature.select("COUNT(*) AS count_all, browser_name, date(created_at) as created_date").group("browser_name, created_date").order(:created_date)
    browsers = results.group_by &:browser_name
    data = browsers.map do |browser, signature|
      { label: browser, data: signature.map {|s| [ s.created_date.to_time.to_i * 1200, s.count_all ]} }
    end

    render json: data
  end
end
