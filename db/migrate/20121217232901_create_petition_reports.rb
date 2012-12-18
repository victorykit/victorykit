class CreatePetitionReports < ActiveRecord::Migration
  def up
    metrics = %w(sent_emails_count signatures_count
      opened_emails_count clicked_emails_count signed_from_emails_count new_members_count unsubscribes_count like_count hit_count
      opened_emails_rate  clicked_emails_rate  signed_from_emails_rate  new_members_rate  unsubscribes_rate  like_rate  hit_rate)
    periods = %w(day week month year)
    columns = periods.map {|p| metrics.map {|m| "#{m}_#{p}" } }.flatten

    create_table :petition_reports do |t|
      t.integer  :petition_id
      t.text     :petition_title
      t.datetime :petition_created_at

      columns.each do |c|
        column_type = (c =~ /rate/) ? :float : :integer
        t.column(c, column_type)
      end
    end

    change_table :petition_reports do |t|
      t.index(:petition_id)
      t.index(:petition_title)
      t.index(:petition_created_at)

      columns.each do |c|
        t.index(c) if c =~ /(rate|sent)/
      end
    end
  end

  def down
    drop_table(:petition_reports)
  end
end
