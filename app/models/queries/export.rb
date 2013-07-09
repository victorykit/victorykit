module Queries
  class Export < Query
    def record_set
      @record_set ||= ActiveRecord::Base.connection.execute(sql)
    end

    def first_row
      @first_row ||= ActiveRecord::Base.connection.execute(sql + " LIMIT 1").to_a.first
    end

    def total_rows
      @total_rows ||= ActiveRecord::Base.connection.execute("select count(*) from (#{sql}) tmp").first['count'].to_i
    end

    def find_in_batches(options = {})
      batch_size = options[:batch_size] || 10000
      primary_key_offset = options[:primary_key_offset] || 0

      records = records_for_batch(batch_size, primary_key_offset)

      while records.any?
        primary_key_offset = records.last['id']

        yield records

        break if records.size < batch_size

        if primary_key_offset
          records = records_for_batch(batch_size, primary_key_offset)
        else
          raise "Primary key not included in the custom select clause"
        end
      end
    end

    def records_for_batch(batch_size, primary_key_offset)
      ActiveRecord::Base.connection.execute(sql_for_batch(batch_size, primary_key_offset)).to_a
    end

    def sql_for_batch(batch_size, primary_key_offset)
      "#{sql} AND #{klass.table_name}.id > #{ActiveRecord::Base.sanitize(primary_key_offset)} ORDER BY #{klass.table_name}.id LIMIT #{ActiveRecord::Base.sanitize(batch_size)}"
    end


    def as_csv_stream
      Enumerator.new do |response_blob|
        if first_row.present?

          # insert the first header row
          response_blob << CSV.generate do |csv|
            csv << header_row
          end

          find_in_batches do |batch|
            response_blob << CSV.generate do |csv|
              batch.each do |row|
                csv << generate_row(row)
              end
            end
          end
        end
      end
    end

    def header_row
      first_row.keys
    end

    def generate_row(row)
      columns = row.keys
      columns.collect do |c|
        row[c]
      end
    end
  end
end