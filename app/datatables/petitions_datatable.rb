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
      aaData: formatted_data
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
        h(petition.new_member_count),
        h(float_to_percentage(petition.virality_rate)),
        h(format_date_time(petition.petition_created_at)),
      ]
    end
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
    columns = %w[petition_title hit_count signature_count conversion_rate new_member_count virality_rate petition_created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? :desc : :asc
  end
end