class AddDeletedFlagToPetitions < ActiveRecord::Migration
  def change
    add_column :petitions, :deleted, :boolean
  end
end
