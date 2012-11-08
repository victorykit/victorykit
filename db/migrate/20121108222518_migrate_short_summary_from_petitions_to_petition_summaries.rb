class MigrateShortSummaryFromPetitionsToPetitionSummaries < ActiveRecord::Migration
  def up
    execute <<-SQL
INSERT INTO petition_summaries (short_summary, petition_id, created_at, updated_at)
SELECT short_summary, id, now(), now()
FROM petitions
WHERE short_summary IS NOT NULL
AND short_summary <> ''
GROUP BY short_summary, id
    SQL
  end
end
