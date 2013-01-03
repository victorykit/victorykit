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
  
  def dpct(numerator, denominator, percentify=true)
    fn = lambda {|x| percentify ? float_to_percentage(x) : x.to_s[0..4]}
    n = denominator.nonzero? ? numerator / denominator.to_f : 0.0
    "<span title='#{numerator}'>" + fn.call(n) + "</span>"
  end

  def format_rate(petition_report, property, percentify=true)
    count = petition_report.send(:"#{property}_count")
    rate  = petition_report.send(:"#{property}_rate")
    display_rate = percentify ? float_to_percentage(rate) : rate.round(3).to_s
    "<span title='#{count}'>#{display_rate}</span>"
  end

  def data
    petitions.map do |petition|
      [
        link_to(petition.petition_title, petition_path(petition.petition_id)),
        h(petition.sent_emails_count).to_i,
        format_rate(petition, :opened_emails),
        format_rate(petition, :clicked_emails),
        format_rate(petition, :signed_from_emails),
        format_rate(petition, :like),
        format_rate(petition, :hit, false),
        format_rate(petition, :new_members),
        format_rate(petition, :unsubscribes),
        h(format_date_time(petition.petition_created_at)),
      ]
    end
  end
  
  def totals
    petition = PetitionStatisticsTotals.new(petitions)
    [
      'All petitions',
      h(petition.sent_emails_count).to_i,
      dpct(petition.opened_emails_count, petition.sent_emails_count),
      dpct(petition.clicked_emails_count, petition.sent_emails_count),
      dpct(petition.signed_from_emails_count, petition.sent_emails_count),
      dpct(petition.like_count, petition.sent_emails_count),
      dpct(petition.hit_count, petition.sent_emails_count, false),
      dpct(petition.new_members_count, petition.sent_emails_count),
      dpct(petition.unsubscribes_count, petition.sent_emails_count),
      '',
    ]
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
end
