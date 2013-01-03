class PetitionReportPresenter
  delegate :petition_id, :petition_title, :petition_created_at, :to => :@report

  def initialize(petition_report, time_span)
    @report = petition_report
    @time_span = time_span
  end

  def method_missing(method)
    value = @report.send(:"#{method}_#{@time_span}")
    if value
      value
    elsif method =~ /rate/
      0.0
    else
      0
    end
  end
end
