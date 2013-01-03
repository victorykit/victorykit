class PetitionReportRepository
  def reports(time_span, property, direction, page=1, per_page=10)
    direction = direction == :asc ? 'ASC NULLS FIRST' : 'DESC NULLS LAST'
    column    = property =~ /(count|rate)/ ? "#{property}_#{time_span}" : property

    PetitionReport.paginate(:page => page, :per_page => per_page).order("#{column} #{direction}").map do |report|
      PetitionReportPresenter.new(report, time_span)
    end
  end

  def totals(time_span)
    count_columns = PetitionReport.column_names.select {|c| c =~ /_count_#{time_span}/ }
    rate_columns  = PetitionReport.column_names.select {|c| c =~ /_rate_#{time_span}/ }

    columns_for_select = ["NULL AS petition_id", "'All Petitions' AS petition_title", "NULL AS petition_created_at"]
    count_columns.each do |column|
      columns_for_select << "SUM(#{column}) AS #{column}"
    end
    rate_columns.each do |column|
      property_total = column.gsub('_rate_', '_count_')
      columns_for_select << "FLOAT4(SUM(#{property_total})) / NULLIF(SUM(sent_emails_count_#{time_span}), 0) AS #{column}"
    end

    totals_report = PetitionReport.select(columns_for_select).first
    PetitionReportPresenter.new(totals_report, time_span)
  end
end