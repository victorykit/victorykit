class ApplicationStatus

  def initialize
    @items = {}
  end

  def [] k
    @items[k]
  end

  def []= k,v
    @items[k] = v
  end

  def ok?
    @ok = @items.values.find_all { |status| status.fails_app? } .all? { |status| status.ok? }
  end

  # ATTENTION: newrelic expects to see "Status: OK" on the page, otherwise it sends out alerts. 
  # So if you change this here, make sure you also update newrelic. Especially if you change it late at night :)
  def text
    ok? ? "OK" : "FAILING"
  end

  # Style for overall application status should apply to both label and value because newrelic doesn't seem to like spans in its substring check.
  def style
    ok? ? "ok" : "failing"
  end

end

class ItemStatus

  def initialize fails_app, down_term="FAILING"
    @fails_app = fails_app
    @down_term = down_term
  end

  def fails_app?
    @fails_app
  end

  def ok?
    @ok
  end

  def style
    @ok ? "ok" : (@fails_app ? "failing" : "warning")
  end

  def text
    @ok ? "OK" : @down_term
  end

end

class EmailStatus < ItemStatus
  attr_accessor :threshold, :last_timestamp, :working

  def initialize fails_app
    super fails_app, "INACTIVE"
    check
  end

  def check
    @threshold = ENV['VK_HEARTBEAT_SENT_EMAIL'].try(:to_i) || 5
    @last_timestamp = SentEmail.last.created_at
    @ok = @last_timestamp > @threshold.minutes.ago
    if not @working
      Rails.logger.error "Heartbeat: emails inactive since #{@last_timestamp}"
    end
    @ok
  end

end

class SignatureStatus < ItemStatus
  attr_accessor :threshold, :last_timestamp, :working

  def initialize fails_app
    super fails_app, "INACTIVE"
  end

  def check
    @threshold = ENV['VK_HEARTBEAT_SIGNATURE'].try(:to_i) || 60
    # Failing on a shortage of signatures turned out to be a bit overzealous, particularly in the middle of the night.
    # Instead, we'll keep it on the page so it's visible for manual checks but not fail over it. We can redefine it as
    # a ratio of signatures per page hit to take late night and holiday fluctuations into account.
    @last_timestamp = Signature.last.created_at
    @ok = @last_timestamp > @threshold.minutes.ago
    if not @working
      Rails.logger.warn "Heartbeat: signatures inactive since #{@last_timestamp}"
    end
    @ok
  end

end

class ResqueStatus < ItemStatus
  attr_accessor :ok, :stats, :max_q

  def initialize fails_app
    super fails_app
    check
  end

  def check
    @stats = Resque.info
    @ok = Resque.info[:workers] > 0 && max_q <= 100
  end

  def max_q
    Resque.queues.max_by { |queue| Resque.size(queue) } .to_i
  end

end
