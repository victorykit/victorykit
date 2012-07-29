module ApplicationMetrics
  def sql(column_name)
  "SELECT day::date, count(s.#{column_name})/nullif(count(s.created_at)::float, 0) as percentage 
        FROM sent_emails s
        RIGHT JOIN generate_series('2012-05-16'::date, current_date, '1 day') as day
        ON s.created_at::date BETWEEN (day::date - 7) AND day::date
        GROUP BY day::date ORDER BY day::date;"
  end

  def opened_emails_percentage
    result = ActiveRecord::Base.connection.execute(sql "opened_at")
    result.map{|row| (v = row.values[1]) ? v : 0}
  end

  def clicked_email_links_percentage
    result = ActiveRecord::Base.connection.execute(sql "clicked_at")
    result.map{|row| (v = row.values[1]) ? v : 0}
  end
end
