class MigrateFacebookDescriptionFromPetitionsToPetitionDescriptions < ActiveRecord::Migration
  def up
    execute <<-SQL
INSERT INTO petition_descriptions (facebook_description, petition_id, created_at, updated_at)
SELECT facebook_description, id, now(), now()
FROM petitions
WHERE facebook_description IS NOT NULL
AND facebook_description <> ''
GROUP BY facebook_description, id
    SQL
  end
end
