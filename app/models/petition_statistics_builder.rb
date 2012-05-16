ANALYTICS_START_DATE = Date.new(2012, 4, 26) #this is when we started with analytics

class PetitionStatisticsBuilder

  def all_since_and_ordered(date, property, direction)
    sorted = all_since(date).sort_by(&property.to_sym)
    direction == :asc ? sorted : sorted.reverse
  end
  
  private
  
  def all_since(date)
    date ||= ANALYTICS_START_DATE
    analytics_report_data = AnalyticsGateway.fetch_report_results(date)
    Petition.all.map do |p|
      petition_path = Rails.application.routes.url_helpers.petition_path(p)
      PetitionStatistics.new(p, analytics_report_data[petition_path], date)
    end
  end
end