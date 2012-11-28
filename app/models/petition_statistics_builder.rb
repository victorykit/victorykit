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

    sent_emails = ScheduledEmail.count(:conditions => ['created_at >= ?', date], :group => 'petition_id')
    opened_emails = ScheduledEmail.count(:conditions => ['created_at >= ? and opened_at is not null', date], :group => 'petition_id')
    clicked_emails = ScheduledEmail.count(:conditions => ['created_at >= ? and clicked_at is not null', date], :group => 'petition_id')
    signed_emails = ScheduledEmail.count(:conditions => ['created_at >= ? and signature_id is not null', date], :group => 'petition_id')
    unsubscribes = ScheduledEmail.count(:conditions => ['unsubscribes.created_at >=?', date], :joins => :unsubscribe, :group => 'petition_id')
    signatures = Signature.count(:conditions => ['created_at >= ?', date], :group => 'petition_id')
    new_members = Signature.count(:conditions => ['created_at >= ? and created_member is true', date], :group => 'petition_id')

    Petition.all.map do |p|
      local_stats = OpenStruct.new(
        sent_emails: sent_emails[p.id] || 0, 
        opened_emails: opened_emails[p.id] || 0, 
        clicked_emails: clicked_emails[p.id] || 0, 
        signed_from_emails: signed_emails[p.id] || 0,
        signatures: signatures[p.id] || 0,
        new_members: new_members[p.id] || 0,
        unsubscribes: unsubscribes[p.id] || 0)
      petition_path = Rails.application.routes.url_helpers.petition_path(p)
      google_stats = analytics_report_data[petition_path]
      PetitionStatistics.new(p, google_stats, local_stats)
    end
  end
end