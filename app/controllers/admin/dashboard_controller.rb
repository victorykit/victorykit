class Admin::DashboardController < ApplicationController

  before_filter :require_admin
  newrelic_ignore

  helper_method :heartbeat, :nps_chart_url, :timeframe_options, :petition_extremes

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

  def timeframe_options
    ["month", "week", "day", "hour"]
  end

  def nps_chart_url
    from = "1#{timeframe}"
u = <<-url
http://graphite.watchdog.net/render?\
target=alias(movingAverage(stats.gauges.victorykit.nps,1440),"moving average (daily)")&\
target=alias(movingAverage(stats.gauges.victorykit.nps,60), "moving average (hourly)")&\
from=-#{from}&\
fontName=Helvetica&fontSize=12&title=New%20members%20per%20email%20sent&\
bgcolor=white&fgcolor=black&colorList=darkgray,red&\
lineWidth=3&\
height=400&width=800&\
format=svg
url
u.strip
  end

  def timeframe
    from_param = scrub_param timeframe_options, params[:f], 'week', "Filter not recognized: #{params[:f]}"
  end

  def scrub_param options, value, default, error
    if value and not options.include? value
      flash.now[:error] = error unless options.include? value
      default
    else
      value || default
    end
  end

  def petition_extremes
    limit = 3
    nps = Metrics::Nps.new.timespan(1.send(timeframe).ago..Time.now).sort_by { |n| n[:nps] }.reverse
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

end