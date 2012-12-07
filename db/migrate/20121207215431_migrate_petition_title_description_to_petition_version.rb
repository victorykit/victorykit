class MigratePetitionTitleDescriptionToPetitionVersion < ActiveRecord::Migration
  def up
      execute <<-SQL
    INSERT INTO petition_versions (title, description, petition_id, created_at, updated_at)
    SELECT title, description, id, created_at, updated_at
    FROM petitions
    ORDER BY id
      SQL
  end
end
