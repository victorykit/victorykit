class AddShortSummaryColumnToPetitions < ActiveRecord::Migration
  def change
    add_column :petitions, :short_summary, :string
  end
end
