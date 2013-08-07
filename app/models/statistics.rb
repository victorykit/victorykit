class Statistics
  include ActiveAttr::Model

  attribute :t,  :default => "week"
  attribute :x,  :default => "3"
  attribute :th, :default => "1000"

  alias_method :timeframe, :t
  alias_method :extremes_count, :x
  alias_method :extremes_threshold, :th

  TIMEFRAMES = ["month", "week", "day", "hour"]
  EXTREMES_COUNTS = ["20", "10", "3"]
  EXTREMES_THRESHOLDS = ["1000", "100", "10"]

  validates_inclusion_of :t,  :in => TIMEFRAMES
  validates_inclusion_of :x,  :in => EXTREMES_COUNTS
  validates_inclusion_of :th, :in => EXTREMES_THRESHOLDS

  def heartbeat
    @heartbeat ||= Admin::Heartbeat.new
    {
      last_email: @heartbeat.last_sent_email,
      last_signature: @heartbeat.last_signature,
      emails_sent_past_week: @heartbeat.emails_sent_since(1.week.ago),
      emailable_member_count: @heartbeat.emailable_members,
      new_members: @heartbeat.new_members
    }
  end

  def average_donations_per_day
    Donation.where("created_at BETWEEN now() - interval'8 days' AND now() - interval'1 day'").group('DATE(created_at)').sum('amount').map { |d| d[1] }.inject(0.0) { |sum, n| sum + n } / 7
  end

  def total_donations
    Donation.sum('amount')
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
    strip_chart "stats.gauges.victorykit.nps", averaging_window, thresholds
  end

  def facebook_actions_chart
    thresholds = [ThresholdLine.good(0.30), ThresholdLine.bad(0.03)]
    strip_chart series_as_email_rate("stats_counts.victorykit.facebook_actions.count"), averaging_window, thresholds
  end

  def facebook_referrals_chart
    thresholds = [ThresholdLine.good(0.10), ThresholdLine.bad(0.03)]
    strip_chart series_as_email_rate("stats_counts.victorykit.facebook_referrals.count"), averaging_window, thresholds
  end

  def unsubscribes_chart
    thresholds = [ThresholdLine.good(0), ThresholdLine.bad(0.02)]
    strip_chart series_as_email_rate("stats_counts.victorykit.unsubscribes.count"), averaging_window, thresholds
  end

  def emails_sent_chart
    thresholds = [ThresholdLine.good(3.75), ThresholdLine.bad(2)]
    strip_chart "stats_counts.victorykit.emails_sent.count", 60, thresholds
  end

  def emails_opened_chart
    thresholds = [ThresholdLine.good(0.75), ThresholdLine.bad(0.5)]
    strip_chart series_as_email_rate("stats_counts.victorykit.emails_opened.count"), averaging_window, thresholds
  end

  def emails_clicked_chart
    thresholds = [ThresholdLine.good(0.75), ThresholdLine.bad(0.5)]
    strip_chart series_as_email_open_rate("stats_counts.victorykit.emails_clicked.count"), averaging_window, thresholds
  end

  def signatures_from_email_chart
    thresholds = [ThresholdLine.good(0.75), ThresholdLine.bad(0.5)]
    strip_chart series_as_email_click_rate("stats_counts.victorykit.signatures_from_emails.count"), averaging_window, thresholds
  end

  def facebook_action_per_signature_chart
    thresholds = [ThresholdLine.good(0.75), ThresholdLine.bad(0.5)]
    strip_chart series_as_signature_rate("stats_counts.victorykit.facebook_actions.count"), averaging_window, thresholds
  end

  def petition_page_load_chart
    thresholds = [ThresholdLine.good(0.75), ThresholdLine.bad(0.5)]
    strip_chart "stats_counts.victorykit.petition_page_load_non_email.count", 60, thresholds
  end

  def signature_per_petition_page_load_chart
    #sometimes graphite screws the chart's scale, causing the graph to appear near-zero relative to the threshold numbers.
    #removing the threshold until we have a better fix
    #thresholds = [ThresholdLine.good(0.75), ThresholdLine.bad(0.5)]
    strip_chart series_as_petition_load_rate("stats_counts.victorykit.signatures.count"), averaging_window #, thresholds
  end

  def averaging_window
    { "month" => 120, "week" => 120, "day" => 60, "hour" => 60}[timeframe]
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

  def strip_chart gauge, averaging_window, thresholds=[]
    from = "1#{timeframe}"
    main = "movingAverage(#{gauge}, #{averaging_window})"
    timeshift = "timeShift(#{main}, '#{from}')"

    baseUri = "http://#{$statsd.host}/render"
u = <<-url
#{baseUri}?\
target=color(lineWidth(#{timeshift}, 2), 'dddddd')&\
target=color(lineWidth(#{main}, 2), 'blue')&\
#{thresholds.join('&')}&\
from=-#{from}&\
bgcolor=white&fgcolor=black&\
graphOnly=false&\
height=180&width=600&\
hideLegend=true&\
format=svg
url
u.strip
  end

  def petition_extremes
    @extremes ||= fetch_petition_extremes(extremes_count.to_i, extremes_threshold.to_i)
  end

  def fetch_petition_extremes count, threshold
    timespan = 1.send(timeframe).ago
    threshold = extremes_threshold.to_i
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
