class Metrics::Nps

  def initialize
    @ignore_member = 79459 # test user (aaron)
    @signature_referer_filter = "(referer_id != #{@ignore_member} or referer_id is null)"
  end

  def single petition
    petition_id = as_id petition
    sent = ScheduledEmail.where(petition_id: petition_id).count
    subscribes = Signature.where(petition_id: petition_id).where(created_member: true).where(@signature_referer_filter).count
    unsubscribes = Unsubscribe.joins(:sent_email).where("sent_emails.petition_id = #{petition_id}").count      
    assemble petition_id, sent, subscribes, unsubscribes
  end

  def multiple petitions
    sent = ScheduledEmail.group(:petition_id).count
    subscribes = Signature.where(created_member: true).where(@signature_referer_filter).group(:petition_id).count
    unsubscribes = Unsubscribe.joins(:sent_email).group(:petition_id).count
    assemble_multiple petitions, sent, subscribes, unsubscribes
  end

  def timespan range, sent_threshold=1000
    sent = ScheduledEmail.where(created_at: range).joins(:petition).where("petitions.to_send = ?", true).group(:petition_id).count
    subscribes = Signature.where(created_at: range).where(created_member: true).where(@signature_referer_filter).group(:petition_id).count
    unsubscribes = SentEmail.group(:petition_id).where(id: Unsubscribe.select("sent_email_id").where("sent_email_id IS NOT NULL").where(created_at: range)).count
    petitions = sent.reject{ |k,v| v < sent_threshold }.keys
    assemble_multiple petitions, sent, subscribes, unsubscribes
  end

  def aggregate since
    sent = ScheduledEmail.where("created_at > ?", since).count
    subscribes = Signature.where("created_at > ?", since).where(created_member: true).where(@signature_referer_filter).count
    unsubscribes  = Unsubscribe.where("cause='unsubscribed' and created_at > ?", since).count
    rates = calculate_rates sent, subscribes, unsubscribes
    {sent: sent, subscribes: subscribes, unsubscribes: unsubscribes}.merge rates
  end

  private

  def assemble petition_id, sent, subscribes, unsubscribes
    rates = calculate_rates(sent, subscribes, unsubscribes)
    {petition_id: petition_id, sent: sent, subscribes: subscribes, unsubscribes: unsubscribes}.merge rates
  end

  def assemble_multiple petitions, sent, subscribes, unsubscribes
    sent.default, subscribes.default, unsubscribes.default = 0, 0, 0
    #todo: why is unsubs ending up keyed with petition id as string?
    petitions.map{ |p| as_id(p) }.map { |id| assemble(id, sent[id], subscribes[id], unsubscribes[id.to_s]) }
  end

  def calculate_rates sent, subscribes, unsubscribes
    sent = sent.nonzero? || 1
    sps = subscribes.to_f / sent.to_f
    ups = unsubscribes.to_f / sent.to_f
    nps = sps - ups
    {sps: sps, ups: ups, nps: nps, }
  end

  def as_id p
    p.respond_to?("id")? p.id : p
  end

end
