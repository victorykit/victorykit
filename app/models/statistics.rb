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
      emailable_member_count: @heartbeat.emailable_members
    }
  end

  def average_donations_per_day
    donations = Donation.recent.group('DATE(created_at)').sum('amount')
    donations.map { |date, sum| sum }.sum / 7.0
  end

  def total_donations
    Donation.sum('amount')
  end

  def nps_7d
    @nps_7d ||= Metrics::Nps.email_aggregate(1.week.ago)
  end

  def nps_24h
    @nps_24h ||= Metrics::Nps.email_aggregate(1.day.ago)
  end

  def nps_60m
    @nps_60m ||= Metrics::Nps.email_aggregate(1.hour.ago)
  end

  def npfs_7d
    @npfs_7d ||= Metrics::Nps.facebook_aggregate(1.week.ago)
  end

  def npfs_24h
    @npfs_24h ||= Metrics::Nps.facebook_aggregate(1.day.ago)
  end

  def npfs_60m
    @npfs_60m ||= Metrics::Nps.facebook_aggregate(1.hour.ago)
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

  def best_petitions
    count    = self.extremes_count.to_i
    best_nps = nps_by_timeframe.first(count)
    Petition.where(id: best_nps.map(&:id)).zip best_nps
  end

  def worst_petitions
    count     = self.extremes_count.to_i
    worst_nps = nps_by_timeframe.last(count) - nps_by_timeframe.first(count)
    Petition.where(id: worst_nps.map(&:id)).zip worst_nps
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

  private

  def nps_by_timeframe
    unless defined?(@nps_by_timeframe)
      timeframe = 1.send(self.timeframe).ago
      threshold = self.extremes_threshold.to_i

      @nps_by_timeframe = Metrics::Nps.email_by_timeframe(
        timeframe, sent_threshold: threshold
      ).sort_by(&:nps).reverse
    end

    @nps_by_timeframe
  end

end
