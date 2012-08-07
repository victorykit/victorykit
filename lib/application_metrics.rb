module ApplicationMetrics
  def count_sql(column_name)
    "SELECT #{column_name}::date, count(s.#{column_name})
    FROM sent_emails s
    WHERE #{column_name} is not null GROUP BY #{column_name}::date;"
  end

  def week_average numerator_column, denominator_column
    denominator_counts = ActiveRecord::Base.connection.execute(count_sql denominator_column)
    denominator_hash = Hash[denominator_counts.map{|row| [row.values[0].to_date, row.values[1].to_f]}]
    denominator_hash.default = 0
    numerator_counts = ActiveRecord::Base.connection.execute(count_sql numerator_column)
    numerator_hash = Hash[numerator_counts.map{|row| [row.values[0].to_date, row.values[1].to_f]}]
    numerator_hash.default = 0
    (Date.new(2012, 05, 16)..Date.today).collect do |x|
      numerator = 0
      (x-6..x).each{|d| numerator += numerator_hash[d] }
      denominator = 0
      (x-6..x).each{|d| denominator += denominator_hash[d] }
      numerator/(denominator == 0 ? 1 : denominator)
    end
  end

  def opened_emails_percentage
    week_average "opened_at", "created_at"
  end

  def clicked_email_links_percentage
    week_average "clicked_at", "created_at"
  end
end


