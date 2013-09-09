class Metrics::Nps
  attr_reader :actions, :subscribes, :unsubscribes, :id

  def initialize(params={})
    @actions      = params[:actions].try(:nonzero?) || 1
    @subscribes   = params[:subscribes] || 0
    @unsubscribes = params[:unsubscribes] || 0
    @id           = params[:id]
  end

  def sps
    subscribes.to_f / actions.to_f
  end

  def ups
    unsubscribes.to_f / actions.to_f
  end

  def net
    subscribes - unsubscribes
  end

  def nps
    sps - ups
  end

  class << self

    def email_by_petition(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      petition_ids = args.flatten.map(&:to_i)

      actions      = ScheduledEmail.where(petition_id: petition_ids).group(:petition_id).count
      subscribes   = Signature.created.where(petition_id: petition_ids).group(:petition_id).count
      unsubscribes = Unsubscribe.not_bounced.joins(:sent_email).where(sent_emails: { petition_id: petition_ids }).group("sent_emails.petition_id").count

      results = petition_ids.map do |id|
        Metrics::Nps.new id: id, actions: actions[id], subscribes: subscribes[id], unsubscribes: unsubscribes[id.to_s]
      end

      # Return a single NPS object if a single petition ID given.
      petition_ids.length == 1 ? results.first : results
    end

    def email_by_timeframe(time_ago, opts={})
      actions      = ScheduledEmail.where("created_at > ?", time_ago).where(:petition_id => Petition.where(to_send: true)).group(:petition_id).count
      subscribes   = Signature.created.where("created_at > ?", time_ago).group(:petition_id).count
      unsubscribes = SentEmail.group(:petition_id).where(id: Unsubscribe.select("sent_email_id").where("sent_email_id IS NOT NULL").where("created_at > ?", time_ago)).count

      # FFS use "having" instead. but this is a refactor. keep it together, guthrie.
      sent_threshold = opts[:sent_threshold] || 1000
      petition_ids = actions.reject{ |k,v| v < sent_threshold }.keys

      petition_ids.map do |id|
        Metrics::Nps.new id: id, actions: actions[id], subscribes: subscribes[id], unsubscribes: unsubscribes[id.to_s]
      end
    end

    def email_aggregate(since)
      actions       = ScheduledEmail.where("created_at > ?", since).count
      subscribes    = Signature.created.where("created_at > ?", since).count
      unsubscribes  = Unsubscribe.where("cause='unsubscribed' and created_at > ?", since).count

      Metrics::Nps.new id: since, actions: actions, subscribes: subscribes, unsubscribes: unsubscribes
    end

    def facebook_aggregate(since)
      actions       = FacebookAction.where("created_at > ?", since).count
      subscribes    = Signature.created.where("created_at > ?", since).count
      unsubscribes  = Unsubscribe.where("cause='unsubscribed' and created_at > ?", since).count

      Metrics::Nps.new id: since, actions: actions, subscribes: subscribes, unsubscribes: unsubscribes
    end

  end

end
