class Admin::ExperimentsController < ApplicationController
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
      suffix = "/spin"
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
        spins = REDIS.zcard("whiplash/#{test_name}/#{opt_name}/spin")
        test_stats[:arms].append({
          name: opt_name,
          spins: spins,
          wins: REDIS.zcard("whiplash/#{test_name}/#{opt_name}/win"),
        })
        test_stats[:trials] += spins
      end
      mystats.append test_stats
    end
    mystats
  end
  
  def index
    @stats = stats
  end
end
