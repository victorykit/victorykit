class PetitionReportRepository
  def all_since_and_ordered(time_span, property, direction)
    direction = direction == :asc ? 'ASC NULLS FIRST' : 'DESC NULLS LAST'
    column    = property =~ /(count|rate)/ ? "#{property}_#{time_span}" : property

    PetitionReport.order("#{column} #{direction}").map do |report|
      PetitionReportPresenter.new(report, time_span || 'year')
    end
  end
end