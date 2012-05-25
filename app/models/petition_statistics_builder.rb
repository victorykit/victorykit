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

    sent_emails = SentEmail.count(:conditions => ['created_at >= ?', date], :group => 'petition_id')
    opened_emails = SentEmail.count(:conditions => ['opened_at >= ?', date], :group => 'petition_id')
    clicked_emails = SentEmail.count(:conditions => ['clicked_at >= ?', date], :group => 'petition_id')
    signed_emails = SentEmail.count(:conditions => ['created_at >= ? and signature_id is not null', date], :group => 'petition_id')
    signatures = Signature.count(:conditions => ['created_at >= ?', date], :group => 'petition_id')
    new_members = Signature.count(:conditions => ['created_at >= ? and created_member is true', date], :group => 'petition_id')
    
    #TODO: convert this sucker to an ActiveRecord query
    unsubscribes = ActiveRecord::Base.connection.execute("SELECT petition_id, COUNT(*) FROM unsubscribes INNER JOIN sent_emails ON sent_emails.id = unsubscribes.sent_email_id WHERE (unsubscribes.created_at >= '#{date}') GROUP BY petition_id").inject({}) {|h, row| h[row["petition_id"].to_i] = row["count"].to_i; h}

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

      PetitionStatistics.new(p, analytics_report_data[petition_path], local_stats)
    end
  end
end