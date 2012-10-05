class Admin::DashboardController < ApplicationController

  before_filter :require_admin
  newrelic_ignore

  helper_method :heartbeat, :nps_chart_url, :timeframe, :petition_extremes, :extremes_count, :extremes_threshold

  def index
    timeframe.verify.tap {|t| flash.now[:error] = t unless not t }
    extremes_count.verify.tap {|t| flash.now[:error] = t unless not t }
    extremes_threshold.verify.tap {|t| flash.now[:error] = t unless not t }
  end

  def heartbeat
    heartbeat = Admin::Heartbeat.new
    {
      last_email: heartbeat.last_sent_email,
      last_signature: heartbeat.last_signature,
      emails_in_queue: heartbeat.emails_in_queue,
      emails_sent_past_week: heartbeat.emails_sent_since(1.week.ago),
      emailable_member_count: heartbeat.emailable_members
    }
  end

  def nps_chart_url
    from = "1#{timeframe.value}"
u = <<-url
http://graphite.watchdog.net/render?\
target=alias(movingAverage(stats.gauges.victorykit.nps,1440),"moving average (daily)")&\
target=alias(movingAverage(stats.gauges.victorykit.nps,60), "moving average (hourly)")&\
target=threshold(0.5, "hot")&\
target=threshold(0.35, "warm")&\
from=-#{from}&\
fontName=Helvetica&fontSize=12&title=New%20members%20per%20email%20sent&\
bgcolor=white&fgcolor=black&colorList=darkgray,red,green,orange&\
lineWidth=3&\
height=400&width=800&\
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
    limit = extremes_count.value.to_i
    timespan = 1.send(timeframe.value).ago..Time.now
    threshold = extremes_threshold.value
    nps = Metrics::Nps.new.timespan(timespan, threshold).sort_by { |n| n[:nps] }.reverse
    best = nps.first(limit)
    worst = nps.last(limit) - best
    {
      best: associate_petitions(best),
      worst: associate_petitions(worst)
    }
  end

  def associate_petitions stats
    ids = stats.map{ |n| n[:petition_id] }
    petitions = Petition.select("id, title").where("id in (?)", ids)
    petitions.map{ |p| [p, stats.find { |s| s[:petition_id] == p.id }]}
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
end