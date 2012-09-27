class NpsTracker
  def snapshot_nps(since=10.minutes.ago)
    sent    = SentEmail.where("created_at > ?", since).count
    created = Signature.where("created_at > ?", since).where(created_member: true).where("referer_id IS NULL OR referer_id != 79459").count
    unsubs  = Unsubscribe.where("created_at > ?", since).count

    sent    += 1 if sent.zero?
    created -= unsubs

    created.to_f / sent.to_f
  end

  def track
    nps = snapshot_nps
    Rails.logger.info "NpsTracker: tracked #{nps}"
    $statsd.gauge "nps", nps
  end
end

NpsTracker.new.track