
class Admin::DashboardController < ApplicationController

  before_filter :require_admin
  newrelic_ignore

  helper_method :heartbeat, :nps_summary, :petition_extremes,
    :nps_chart, :emails_sent_chart, :emails_opened_chart, :emails_clicked_chart, :unsubscribes_chart,
    :facebook_actions_chart, :facebook_referrals_chart, :facebook_action_per_signature_chart,
    :signatures_from_email_chart, :petition_page_load_chart, :signature_per_petition_page_load_chart,
    :timeframe, :extremes_count, :extremes_threshold, :nps_thresholds, :map_to_threshold

  def index
    verify
  end

  def funnel
    verify
  end

  def verify
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
      emailable_member_count: @heartbeat.emailable_members,
      new_members: @heartbeat.new_members
    }
  end

  def nps_summary
    @nps_summary ||= fetch_nps_summary
  end

  def fetch_nps_summary
    nps7d = Metrics::Nps.new.aggregate(1.week.ago)
    nps24h = Metrics::Nps.new.aggregate(1.day.ago)
    nps60m = Metrics::Nps.new.aggregate(1.hour.ago)
    {
      nps7d: nps7d[:nps],
      sps7d: nps7d[:sps],
      ups7d: nps7d[:ups],
      nps24h: nps24h[:nps],
      sps24h: nps24h[:sps],
      ups24h: nps24h[:ups],
      nps60m: nps60m[:nps],
      sps60m: nps60m[:sps],
      ups60m: nps60m[:ups]
    }
  end

  def nps_chart
    thresholds = [ThresholdLine.good(0.05), ThresholdLine.bad(0)]
    strip_chart timeframe.value, "stats.gauges.victorykit.nps", averaging_window, thresholds
  end

  def facebook_actions_chart
    thresholds = [ThresholdLine.good(0.30), ThresholdLine.bad(0.03)]
    strip_chart timeframe.value, series_as_email_rate("stats_counts.victorykit.facebook_actions.count"), averaging_window, thresholds
  end

  def facebook_referrals_chart
    thresholds = [ThresholdLine.good(0.10), ThresholdLine.bad(0.03)]
    strip_chart timeframe.value, series_as_email_rate("stats_counts.victorykit.facebook_referrals.count"), averaging_window, thresholds
  end

  def unsubscribes_chart
    thresholds = [ThresholdLine.good(0), ThresholdLine.bad(0.02)]
    strip_chart timeframe.value, series_as_email_rate("stats_counts.victorykit.unsubscribes.count"), averaging_window, thresholds
  end

  def emails_sent_chart
    thresholds = [ThresholdLine.good(3.75), ThresholdLine.bad(2)]
    strip_chart timeframe.value, "stats_counts.victorykit.emails_sent.count", 60, thresholds
  end

  def emails_opened_chart
    thresholds = [ThresholdLine.good(0.75), ThresholdLine.bad(0.5)]
    strip_chart timeframe.value, series_as_email_rate("stats_counts.victorykit.emails_opened.count"), averaging_window, thresholds
  end

  def emails_clicked_chart
    thresholds = [ThresholdLine.good(0.75), ThresholdLine.bad(0.5)]
    strip_chart timeframe.value, series_as_email_open_rate("stats_counts.victorykit.emails_clicked.count"), averaging_window, thresholds
  end

  def signatures_from_email_chart
    thresholds = [ThresholdLine.good(0.75), ThresholdLine.bad(0.5)]
    strip_chart timeframe.value, series_as_email_click_rate("stats_counts.victorykit.signatures_from_emails.count"), averaging_window, thresholds
  end

  def facebook_action_per_signature_chart
    thresholds = [ThresholdLine.good(0.75), ThresholdLine.bad(0.5)]
    strip_chart timeframe.value, series_as_signature_rate("stats_counts.victorykit.facebook_actions.count"), averaging_window, thresholds
  end

  def petition_page_load_chart
    thresholds = [ThresholdLine.good(0.75), ThresholdLine.bad(0.5)]
    strip_chart timeframe.value, "stats_counts.victorykit.petition_page_load_non_email.count", 60, thresholds
  end

  def signature_per_petition_page_load_chart
    thresholds = [ThresholdLine.good(0.75), ThresholdLine.bad(0.5)]
    strip_chart timeframe.value, series_as_petition_load_rate("stats_counts.victorykit.signatures.count"), averaging_window, thresholds
  end

  def averaging_window
    { "month" => 120, "week" => 120, "day" => 60, "hour" => 60}[timeframe.value]
  end

  def series_as_email_rate series
    "divideSeries(#{series}, stats_counts.victorykit.emails_sent.count)"
  end

  def series_as_email_open_rate series
    "divideSeries(#{series}, stats_counts.victorykit.emails_opened.count)"
  end

  def series_as_email_click_rate series
    "divideSeries(#{series}, stats_counts.victorykit.emails_clicked.count)"
  end

  def series_as_signature_rate series
    "divideSeries(#{series}, stats_counts.victorykit.signatures.count)"
  end

  def series_as_petition_load_rate series
    "divideSeries(#{series}, stats_counts.victorykit.petition_page_load_non_email.count)"
  end

  def strip_chart timeframe, gauge, averaging_window, thresholds=[]
    from = "1#{timeframe}"
    main = "movingAverage(#{gauge}, #{averaging_window})"
    timeshift = "timeShift(#{main}, '#{from}')"
u = <<-url
http://graphite.watchdog.net/render?\
target=color(lineWidth(#{timeshift}, 2), 'dddddd')&\
target=color(lineWidth(#{main}, 2), 'blue')&\
#{thresholds.join('&')}&\
from=-#{from}&\
bgcolor=white&fgcolor=black&\
graphOnly=true&\
height=50&width=600&\
format=svg
url
u.strip
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

    def self.good value
      threshold_line value, 'green'
    end

    def self.moderate value
      threshold_line value, 'grey'
    end

    def self.bad value
      threshold_line value, 'red'
    end

    def self.threshold_line value, color
      "target=color(lineWidth(threshold(#{value}), 1), '#{color}')"
    end
  end

end
