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

  VALID_FILTERS = ["experiments", "petitions", "both"]

  def index
    @filter = params[:f] || "experiments"
    @options = VALID_FILTERS
    render text: "Filter not recognized: #{@filter}", status: :not_found unless VALID_FILTERS.include?(@filter)

    @stats = case @filter
    when "both"
      stats
    when "petitions"
      stats.select{|x| x[:name].match /^petition \d+/}.reverse
    when "experiments"
      stats.select{|x| !x[:name].match /^petition \d+/}
    end
  end
end