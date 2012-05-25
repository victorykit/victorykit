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

    sent_emails = count_by_petition("SELECT petition_id, COUNT(*) FROM sent_emails WHERE (created_at >= '#{date}') and petition_id is not null GROUP BY petition_id")
    opened_emails = count_by_petition("SELECT petition_id, COUNT(*) FROM sent_emails WHERE (opened_at >= '#{date}') and petition_id is not null GROUP BY petition_id")
    clicked_emails = count_by_petition("SELECT petition_id, COUNT(*) FROM sent_emails WHERE (clicked_at >= '#{date}') and petition_id is not null GROUP BY petition_id")
    signed_emails = count_by_petition("SELECT petition_id, COUNT(*) FROM sent_emails WHERE (created_at >= '#{date}') and petition_id is not null and signature_id is not NULL GROUP BY petition_id")
    signatures = count_by_petition("SELECT petition_id, COUNT(*) FROM signatures WHERE petition_id is not null and (created_at >= '#{date}') GROUP BY petition_id")
    new_members = count_by_petition("SELECT petition_id, COUNT(*) FROM signatures WHERE petition_id is not null and (created_at >= '#{date}') and created_member is true GROUP BY petition_id")
    unsubscribes = count_by_petition("SELECT petition_id, COUNT(*) FROM unsubscribes INNER JOIN sent_emails ON sent_emails.id = unsubscribes.sent_email_id WHERE (unsubscribes.created_at >= '#{date}') GROUP BY petition_id")

    Petition.all.map do |p|
      local_stats = {
        sent_emails: sent_emails[p.id] || 0, 
        opened_emails: opened_emails[p.id] || 0, 
        clicked_emails: clicked_emails[p.id] || 0, 
        signed_from_emails: signed_emails[p.id] || 0,
        signatures: signatures[p.id] || 0,
        new_members: new_members[p.id] || 0,
        unsubscribes: unsubscribes[p.id] || 0}

      petition_path = Rails.application.routes.url_helpers.petition_path(p)

      PetitionStatistics.new(p, analytics_report_data[petition_path], date, local_stats)
    end
  end

  def count_by_petition sql
    ActiveRecord::Base.connection.execute(sql).inject({}) {|h, row| h[row["petition_id"].to_i] = row["count"].to_i; h}
  end
end