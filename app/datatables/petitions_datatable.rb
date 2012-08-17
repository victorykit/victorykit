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
  delegate :params, :h, :float_to_percentage, :format_date_time, :link_to, to: :@view
    
  def initialize(view, statistics_builder)
    @view = view
    @statistics_builder = statistics_builder
  end
  
  def petitions
    @petitions ||= @statistics_builder.all_since_and_ordered(analytics_since, sort_column, sort_direction) 
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
  
  def data
    petitions.map do |petition|
      [
        link_to(petition.p.title, petition.p),
        h(petition.email_count),
        dpct(petition.opened_emails_count, petition.email_count),
        dpct(petition.clicked_emails_count, petition.email_count),
        dpct(petition.email_signature_count, petition.email_count),
        dpct(petition.likes_count, petition.email_count),
        dpct(petition.hit_count, petition.email_count, false),
        dpct(petition.new_member_count, petition.email_count),
        dpct(petition.unsubscribe_count, petition.email_count),
        h(format_date_time(petition.p.created_at)),
      ]
    end
  end
  
  def totals
    petition = PetitionStatisticsTotals.new(petitions)
    [
      'All petitions',
      h(petition.email_count),
      dpct(petition.opened_emails_count, petition.email_count),
      dpct(petition.clicked_emails_count, petition.email_count),
      dpct(petition.email_signature_count, petition.email_count),
      dpct(petition.likes_count, petition.email_count),
      dpct(petition.hit_count, petition.email_count, false),
      dpct(petition.new_member_count, petition.email_count),
      dpct(petition.unsubscribe_count, petition.email_count),
      '',
    ]
  end

  def sort_column
    columns = %w[petition_title email_count open_rate clicked_rate sign_rate like_rate hit_rate new_rate unsub_rate petition_created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def analytics_since
    since = params[:since]
    since.nil? ? nil : since.to_date
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
