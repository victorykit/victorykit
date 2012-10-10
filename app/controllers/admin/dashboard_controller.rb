class Admin::DashboardController < ApplicationController

  before_filter :require_admin
  newrelic_ignore

  helper_method :heartbeat, :nps_summary, :petition_extremes,
    :nps_chart_url, :emails_sent_chart_url, :unsubscribes_chart_url, :facebook_referrals_chart_url,
    :timeframe, :extremes_count, :extremes_threshold, :nps_thresholds, :map_to_threshold

  def index
    timeframe.verify.tap {|error| flash.now[:error] = error unless not error }
    extremes_count.verify.tap {|error| flash.now[:error] = error unless not error }
    extremes_threshold.verify.tap {|error| flash.now[:error] = error unless not error }
  end

  def heartbeat
    @heartbeat ||= Admin::Heartbeat.new
    {
      last_email: @heartbeat.last_sent_email,
      last_signature: @heartbeat.last_signature,
      emails_in_queue: @heartbeat.emails_in_queue,
      emails_sent_past_week: @heartbeat.emails_sent_since(1.week.ago),
      emailable_member_count: @heartbeat.emailable_members
    }
  end

  def nps_summary
    @nps_summary ||= fetch_nps_summary
  end

  def fetch_nps_summary
    nps24h = Metrics::Nps.new.aggregate(1.day.ago)
    nps7d = Metrics::Nps.new.aggregate(1.week.ago)
    {
      nps24h: nps24h[:nps],
      nps7d: nps7d[:nps],
      ups24h: nps24h[:ups],
      ups7d: nps7d[:ups]
    }
  end

  def nps_chart_url
    thresholds = [
      ThresholdLine.hot(nps_thresholds["hot"]),
      ThresholdLine.mid(nps_thresholds["warm"]),
      ThresholdLine.crisis(0)]
    strip_chart_url timeframe.value, "stats.gauges.victorykit.nps", 90, thresholds
  end

  def facebook_referrals_chart_url
    thresholds = [ThresholdLine.hot(0.10), ThresholdLine.crisis(0.03)]
    strip_chart_url timeframe.value, "stats_counts.victorykit.facebook_referrals.count", 90, thresholds
  end

  def unsubscribes_chart_url
    thresholds = [ThresholdLine.crisis(0.03), ThresholdLine.hot(0)]
    strip_chart_url timeframe.value, "stats_counts.victorykit.unsubscribes.count", 60, thresholds
  end

  def emails_sent_chart_url
    thresholds = [ThresholdLine.crisis(2), ThresholdLine.hot(2.75)]
    strip_chart_url timeframe.value, "stats_counts.victorykit.emails_sent.count", 10, thresholds
  end

  def strip_chart_url timeframe, gauge, averaging_window, thresholds=[]
    from = "1#{timeframe}"
u = <<-url
http://graphite.watchdog.net/render?\
#{thresholds.join('&')}&\
target=color(lineWidth(movingAverage(#{gauge},#{averaging_window}), 2), 'blue')&\
from=-#{from}&\
bgcolor=white&fgcolor=black&\
graphOnly=true&\
height=50&width=600&\
format=svg
url
u.strip
  end

  def nps_thresholds
    {
      "warm" => 0.035,
      "hot" => 0.05
    }
  end

  def timeframe
    @timeframe ||= Options.new(["month", "week", "day", "hour"], "week", params, :t)
  end

  def extremes_count
    @extremes_count ||= Options.new(["20", "10", "3"], "3", params, :x)
  end

  def extremes_threshold
    @extremes_threshold ||= Options.new(["1000", "100", "10"], "1000", params, :th)
  end

  def petition_extremes
    @extremes ||= fetch_petition_extremes(timeframe.value, extremes_count.value.to_i, extremes_threshold.value.to_i)
  end

  def fetch_petition_extremes timeframe, count, threshold
    timespan = 1.send(timeframe).ago..Time.now
    threshold = extremes_threshold.value.to_i
    nps = Metrics::Nps.new.timespan(timespan, threshold).sort_by { |n| n[:nps] }.reverse
    best = nps.first(count)
    worst = nps.last(count) - best
    {
      best: associate_petitions(best),
      worst: associate_petitions(worst)
    }
  end

  def associate_petitions stats
    ids = stats.map{ |n| n[:petition_id] }
    petitions = Petition.select("id, title").where("id in (?)", ids)
    stats.map {|s| [petitions.find {|p| p.id == s[:petition_id]}, s]}
  end

  def map_to_threshold value, thresholds
    thresholds.inject(thresholds[nil]){|result, pair| (pair[0] and value >= pair[0]) ? pair[1] : result  }
  end

  class Options

    def initialize options, default, params, param_key
      @options = options
      @default = default
      @params = params
      @param_key = param_key
    end

    def options
      @options
    end

    def verify
      error = "Option not recognized: #{value}" if not valid?
      scrub
      return error
    end

    def key
      @param_key
    end

    def value
      @params[key]
    end

    private

    def valid?
      value.nil? or options.include? value
    end

    def scrub
      @params[key] = @default if (not valid? or value.nil?)
    end

  end

  class ThresholdLine

    def self.hot value
      threshold_line value, '66CC66'
    end

    def self.mid value
      threshold_line value, 'grey'
    end

    def self.crisis value
      threshold_line value, '7E2217'
    end

    def self.threshold_line value, color
      "target=color(lineWidth(threshold(#{value}), 1), '#{color}')"
    end
  end

end
