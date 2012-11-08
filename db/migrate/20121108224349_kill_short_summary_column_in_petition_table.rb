class KillShortSummaryColumnInPetitionTable < ActiveRecord::Migration
  def up
    remove_column :petitions, :short_summary
  end
end
