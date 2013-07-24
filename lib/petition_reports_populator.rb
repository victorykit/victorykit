class PetitionReportsPopulator

  PERIODS = {
    day:   Time.now - 1.day,
    week:  Time.now - 1.week,
    month: Time.now - 1.month,
    year:  Time.now - 1.year
  }

  METRICS = {
    sent_emails_count:        lambda {|time| email_count_query("created_at >= '#{time.to_s(:db)}'") },
    opened_emails_count:      lambda {|time| email_count_query("created_at >= '#{time.to_s(:db)}' and opened_at is not null") },
    clicked_emails_count:     lambda {|time| email_count_query("created_at >= '#{time.to_s(:db)}' and clicked_at is not null") },
    signed_from_emails_count: lambda {|time| email_count_query("created_at >= '#{time.to_s(:db)}' and signature_id is not null") },
    unsubscribes_count:       lambda {|time| email_count_query("unsubscribes.created_at >= '#{time.to_s(:db)}'", 'inner join unsubscribes on sent_email_id = sent_emails.id') },
    signatures_count:         lambda {|time| signatures_count_query("created_at >= '#{time.to_s(:db)}'") },
    new_members_count:        lambda {|time| signatures_count_query("created_at >= '#{time.to_s(:db)}' and created_member is true") },
    like_count:               lambda {|time| like_count_query("created_at >= '#{time.to_s(:db)}'") }
  }

  class << self
    def populate
      ActiveRecord::Base.transaction do
        db = ActiveRecord::Base.connection
        db.execute create_reports_query

        analytics_data_per_period = {}
        PERIODS.each do |period, starting_time|
          analytics_data_per_period[period] = AnalyticsGateway.fetch_report_results(starting_time)

          METRICS.each do |metric, metric_sql|
            column_name  = "#{metric}_#{period}"
            select_query = metric_sql.call(starting_time)

            db.execute update_count_query(column_name, select_query)
          end
        end

        PetitionReport.all.each do |report|
          petition_path = Rails.application.routes.url_helpers.petition_path(report.petition_id)
          PERIODS.each do |period, _|
            method = :"hit_count_#{period}="
            pageviews = analytics_data_per_period[period][petition_path].try(:unique_pageviews).try(:to_i)
            report.send(method, pageviews)
          end
          report.save if report.changed?
        end

        rate_columns = PetitionReport.column_names.select {|name| name =~ /rate/ }
        rate_columns.each do |column|
          db.execute update_rate_query(column)
        end
      end
    end

    protected

    def email_count_query(conditions, joins='')
      <<-SQL
        SELECT petition_id, COUNT(*) as total
        FROM #{ScheduledEmail.table_name}
        #{joins}
        WHERE type = 'ScheduledEmail' AND #{conditions}
        GROUP BY petition_id
      SQL
    end

    def signatures_count_query(conditions)
      <<-SQL
        SELECT petition_id, COUNT(*) as total
        FROM #{Signature.table_name}
        WHERE #{conditions}
        GROUP BY petition_id
      SQL
    end

    def like_count_query(conditions)
      <<-SQL
        SELECT petition_id, COUNT(*) as total
        FROM #{FacebookAction.table_name}
        WHERE #{conditions}
        GROUP BY petition_id
      SQL
    end

    def create_reports_query
      <<-SQL
        INSERT INTO petition_reports (petition_id, petition_title, petition_created_at)
        SELECT id, title, created_at
        FROM petitions
        WHERE NOT EXISTS (SELECT 1 FROM petition_reports WHERE petition_reports.petition_id = petitions.id)
      SQL
    end

    def update_count_query(column, select_query)
      <<-SQL
        UPDATE petition_reports
        SET #{column} = counts.total
        FROM (#{select_query}) as counts
        WHERE counts.petition_id = petition_reports.petition_id
      SQL
    end

    def update_rate_query(rate_column)
      count_column = rate_column.gsub('rate', 'count')
      total_column = "sent_emails_count_" + rate_column.split('_').last
      <<-SQL
        UPDATE petition_reports
        SET #{rate_column} = (float8(#{count_column}) / float8(#{total_column}))
      SQL
    end
  end
end
