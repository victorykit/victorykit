# see http://datatables.net/usage/server-side for details on how datatables work, params, etc
class PetitionsDatatable
  delegate :params, :h, :float_to_percentage, :format_date_time, :link_to, to: :@view
    
  def initialize(view, statistics_builder)
    @view = view
    @statistics_builder = statistics_builder
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
      [
        link_to(petition.petition_title, petition.petition_record),
        h(petition.hit_count),
        h(petition.signature_count),
        h(float_to_percentage(petition.conversion_rate)),
        h(petition.email_count),
        h("#{petition.opened_emails_count} (#{float_to_percentage(petition.opened_emails_percentage)})"),
        h(petition.email_signature_count),
        h(float_to_percentage(petition.email_conversion_rate)),
        h(petition.new_member_count),
        h(float_to_percentage(petition.virality_rate)),
        h("#{petition.likes} (#{float_to_percentage(petition.likes_percentage)})"),
        h(format_date_time(petition.petition_created_at)),
      ]
    end
  end
  
  def totals
    totaller = PetitionStatisticsTotals.new(petitions)
    [
      'All petitions',
      h(totaller.hit_count),
      h(totaller.signature_count),
      h(float_to_percentage(totaller.conversion_rate)),
      h(totaller.email_count),
      h("#{totaller.opened_emails_count} (#{float_to_percentage(totaller.opened_emails_percentage)})"),
      h(totaller.email_signature_count),
      h(float_to_percentage(totaller.email_conversion_rate)),
      h(totaller.new_member_count),
      h(float_to_percentage(totaller.virality_rate)),
      h("#{totaller.likes} (#{float_to_percentage(totaller.likes_percentage)})"),
      '',
    ]
  end

  def petitions
    @petitions ||= @statistics_builder.all_since_and_ordered(analytics_since, sort_column, sort_direction) 
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

  def sort_column
    columns = %w[petition_title hit_count signature_count conversion_rate email_count email_signature_count email_conversion_rate new_member_count virality_rate petition_created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? :desc : :asc
  end
end
