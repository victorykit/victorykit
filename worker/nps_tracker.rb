class NpsTracker

  def snapshot_nps(since=10.minutes.ago)
    Metrics::Nps.new.aggregate(since)[:nps]
  end

  def track
    nps = snapshot_nps
    Rails.logger.info "NpsTracker: tracked #{nps}"
    $statsd.gauge "nps", nps
  end

end

NpsTracker.new.track