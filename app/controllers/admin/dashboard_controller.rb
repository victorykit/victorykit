class Admin::DashboardController < ApplicationController

  before_filter :require_admin
  newrelic_ignore

  helper_method :heartbeat, :nps_chart_url, :nps_chart_from_options

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

  def nps_chart_from_options
    ["month", "week", "day", "hour"]
  end

  def nps_chart_url
    from_param = validate_param nps_chart_from_options, params[:f], 'week', "Filter not recognized: #{params[:f]}"
    from = "1#{from_param}"
<<-url
http://graphite.watchdog.net/render?\
target=movingAverage(stats.gauges.victorykit.nps,1440)&\
target=movingAverage(stats.gauges.victorykit.nps,60)&\
from=-#{from}&\
fontName=Helvetica&fontSize=12&title=New%20members%20per%20email%20sent&\
bgcolor=white&fgcolor=black&colorList=darkgray,red&\
lineWidth=3&\
height=400&width=800&
format=svg
url
  end

  def validate_param options, value, default, error
    if value and not options.include? value
      flash.now[:error] = error unless options.include? value
      default
    else
      value || default
    end
  end

end