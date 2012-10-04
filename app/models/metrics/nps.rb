class Metrics::Nps

  def initialize
    @ignore_member = 79459 # test user (aaron)
    @signature_referer_filter = "(referer_id != #{@ignore_member} or referer_id is null)"
  end

  def single petition
    petition_id = as_id petition
    sent = SentEmail.select(:id).where(petition_id: petition_id).count
    subscribes = Signature.where(petition_id: petition_id).where(created_member: true).where(@signature_referer_filter).count
    unsubscribes = Unsubscribe.joins(:sent_email).where("sent_emails.petition_id = #{petition_id}").count      
    assemble petition_id, sent, subscribes, unsubscribes
  end

  def multiple petitions
    sent = SentEmail.group(:petition_id).count
    subscribes = Signature.where(created_member: true).where(@signature_referer_filter).group(:petition_id).count
    unsubscribes = Unsubscribe.joins(:sent_email).group(:petition_id).count
    assemble_multiple petitions, sent, subscribes, unsubscribes
  end

  def timespan range
    subscribes = Signature.where(created_at: range).where(created_member: true).where(@signature_referer_filter).group(:petition_id).count
    unsubscribes = Unsubscribe.joins(:sent_email).where(created_at: range).group(:petition_id).count
    ids = (subscribes.keys | unsubscribes.keys).join(',')
    sent = SentEmail.where("petition_id in (#{ids})").group(:petition_id).count
    petitions = sent.keys
    assemble_multiple petitions, sent, subscribes, unsubscribes
  end

  def overall since
    sent = SentEmail.where("created_at > ?", since).count
    subscribes = Signature.where("created_at > ?", since).where(created_member: true).where("referer_id IS NULL OR referer_id != 79459").count
    unsubscribes  = Unsubscribe.where("created_at > ?", since).count
    nps = calculate sent, subscribes, unsubscribes
    {sent: sent, subscribes: subscribes, unsubscribes: unsubscribes, nps: nps}
  end

  private

  def assemble petition_id, sent, subscribes, unsubscribes
    nps = calculate sent, subscribes, unsubscribes
    {petition_id: petition_id, sent: sent, subscribes: subscribes, unsubscribes: unsubscribes, nps: nps}
  end

  def assemble_multiple petitions, sent, subscribes, unsubscribes
    sent.default, subscribes.default, unsubscribes.default = 0, 0, 0
    #todo: why is unsubs ending up keyed with petition id as string?
    petitions.map{ |p| as_id(p) }.map { |id| assemble(id, sent[id], subscribes[id], unsubscribes[id.to_s]) }
  end

  def calculate sent, subscribes, unsubscribes
    sent = sent.nonzero? || 1
    nps = (subscribes - unsubscribes).to_f / sent.to_f
  end

  def as_id p
    p.respond_to?("id")? p.id : p
  end

end
