class PetitionReportPresenter
  delegate :petition_id, :petition_title, :petition_created_at, :to => :@report

  def initialize(petition_report, time_span)
    @report = petition_report
    @time_span = time_span
  end

  def method_missing(method)
    @report.send(:"#{method}_#{@time_span}") || 0.0
  end
end
