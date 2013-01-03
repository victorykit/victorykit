# see http://datatables.net/usage/server-side for details on how datatables work, params, etc
=begin
HOW TO EDIT THE DATATABLE

1. Update index.html.haml
2. Update PetitionsDataTable.data
  a. This may require updating PetitionStatistics
3. Update PetitionsDataTable.totals
4. Update PetitionsDataTable.sort_column.columns
  a. This may require updating PetitionStatistics
5. Add/remove a sorting column from petitions.js.coffee if required
=end

class PetitionsDatatable
  delegate :params, :h, :float_to_percentage, :format_date_time, :link_to, :petition_path, to: :@view
    
  def initialize(view, statistics_builder)
    @view = view
    @statistics_builder = statistics_builder
  end
  
  def petitions
    @petitions ||= @statistics_builder.all_since_and_ordered(time_span, sort_column, sort_direction)
  end
  
  def as_json(options = {})
    formatted_data = Kaminari.paginate_array(data).page(page).per(per_page)
    count = petitions.count
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: count,
      iTotalDisplayRecords: count,
      aaData: formatted_data + [totals]
    }
  end
  
  private

  def data
    petitions.map do |petition|
      format_row(petition)
    end
  end
  
  def totals
    petition = @statistics_builder.totals(time_span)
    format_row(petition)
  end

  def sort_column
    columns = %w[petition_title sent_emails_count opened_emails_rate clicked_emails_rate signed_from_emails_rate like_rate hit_rate new_members_rate unsubscribes_rate petition_created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def time_span
    params[:since] || 'year'
  end
  
  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? :desc : :asc
  end

  def format_row(report)
    [
      report.petition_id ? link_to(report.petition_title, petition_path(report.petition_id)) : report.petition_title,
      h(report.sent_emails_count).to_i,
      format_rate(report, :opened_emails),
      format_rate(report, :clicked_emails),
      format_rate(report, :signed_from_emails),
      format_rate(report, :like),
      format_rate(report, :hit, false),
      format_rate(report, :new_members),
      format_rate(report, :unsubscribes),
      report.petition_created_at ? h(format_date_time(report.petition_created_at)) : '',
    ]
  end

  def format_rate(report, property, percentify=true)
    count = report.send(:"#{property}_count")
    rate  = report.send(:"#{property}_rate")
    display_rate = percentify ? float_to_percentage(rate) : rate.to_s[0..4]
    "<span title='#{count}'>#{display_rate}</span>"
  end
end
