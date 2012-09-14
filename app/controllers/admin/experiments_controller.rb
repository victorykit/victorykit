class Admin::ExperimentsController < ApplicationController
  include ApplicationMetrics
  newrelic_ignore
  before_filter :require_admin
    
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
        spins = spins_for(test_name, opt_name)
        test_stats[:arms].append({
          name: opt_name,
          spins: spins,
          wins: wins_for(test_name, opt_name)
        })
        test_stats[:trials] += spins
      end
      test_stats[:arms].sort! { |x,y| x[:name] <=> y[:name] }
      mystats.append test_stats unless test_name.starts_with? "email_scheduler"
    end

    mystats.sort! { |x,y| compare_stats x, y }
  end

  #not bulletproof, but works with form like "petition 110 etc" (doesn't sort anything right of the number, though)
  def compare_stats x, y
    xname = x[:name]
    yname = y[:name]
    petition_id_pattern = /^petition (\d+)/
    xmatch = xname.match petition_id_pattern
    ymatch = yname.match petition_id_pattern
    if xmatch && ymatch
      xmatch[1].to_i <=> ymatch[1].to_i
    else
      xname <=> yname
    end
  end

  VALID_FILTERS = ["experiments", "petitions", "both"]

  def index
    @filter = params[:f] || "experiments"
    @options = VALID_FILTERS
    render text: "Filter not recognized: #{@filter}", status: :not_found unless VALID_FILTERS.include?(@filter)

    respond_to do |format|
      format.html {
        @redis_used = redis_used
      }
    end

    @stats = case @filter
    when "both"
      stats
    when "petitions"
      stats.select{|x| x[:name].match /^petition \d+/}.reverse
    when "experiments"
      stats.select{|x| !x[:name].match /^petition \d+/}
    end
  end

  def redis_used
    used = Whiplash.redis.info["used_memory"]
    max = ENV['MAX_REDIS_SPACE'] || -1
    return used, (used.to_f/max.to_f)
  end
end