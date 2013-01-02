class PetitionReportPresenter
  delegate :petition_id, :petition_title, :petition_created_at, :to => :@report

  def initialize(petition_report, time_span)
    @report = petition_report
    @time_span = time_span
  end

  def method_missing(method)
    @report.send(:"#{method}_#{@time_span}") || 0.0
  end

  # TODO: change datatable so sorting properties match database columns, eliminating the need for these crazy methods
  def p; Petition.new end

  def email_count; @report.send(:"sent_emails_count_#{@time_span}") || 0 end
  def signature_count; @report.send(:"signatures_count_#{@time_span}") || 0 end
  def email_signature_count; @report.send(:"signed_from_emails_count_#{@time_span}") || 0 end
  def new_member_count; @report.send(:"new_members_count_#{@time_span}") || 0 end
  def unsubscribe_count; @report.send(:"unsubscribes_count_#{@time_span}") || 0 end
  def likes_count; @report.send(:"like_count_#{@time_span}") || 0 end

  def open_rate; @report.send(:"opened_emails_rate_#{@time_span}") || 0.0 end
  def clicked_rate; @report.send(:"clicked_emails_rate_#{@time_span}") || 0.0 end
  def sign_rate; @report.send(:"signatures_rate_#{@time_span}") || 0.0 end
  def new_rate; @report.send(:"new_members_count_#{@time_span}") || 0.0 end
  def unsub_rate; @report.send(:"unsubscribes_rate_#{@time_span}") || 0.0 end
end
